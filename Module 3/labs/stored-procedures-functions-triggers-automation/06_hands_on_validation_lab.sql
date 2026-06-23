-- ============================================================
-- MODULE 3 HANDS-ON LAB
-- FILE 06: AUTOMATED DATA VALIDATION LAB
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- This lab combines stored procedures, validation rules, execution logs,
-- error logs, and result reporting.
-- Goal 1: interpret procedure execution logs to find error-handling gaps.
-- Goal 2: build an automated validation stored procedure with comprehensive
-- error handling and logging.

-- ============================================================
-- 1. REVIEW STAGING DATA WITH INTENTIONAL ISSUES
-- ============================================================

SELECT
    SubmissionID,
    InstitutionCode,
    ReportingPeriod,
    ReportType,
    TotalAssets,
    TotalLiabilities,
    CapitalAdequacyRatio,
    LiquidityCoverageRatio,
    SubmissionStatus
FROM m3.StagingRegulatorySubmissions
ORDER BY SubmissionID;
GO

-- Add one more lab issue for the validation run.
-- This row is valid enough to be loaded, but has low liquidity coverage.
IF NOT EXISTS (
    SELECT 1
    FROM m3.StagingRegulatorySubmissions
    WHERE InstitutionCode = 'RCH'
      AND ReportingPeriod = '2026-03-31'
      AND ReportType = 'Clearing House'
      AND LiquidityCoverageRatio = 87.5000
)
BEGIN
    INSERT INTO m3.StagingRegulatorySubmissions
        (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt)
    VALUES
        ('RCH', '2026-03-31', 'Clearing House', 76000000.00, 61000000.00, NULL, 87.5000, 'Submitted', SYSUTCDATETIME());
END;
GO

-- ============================================================
-- 2. INTERPRET EXECUTION LOGS AND DIAGNOSE A LOGGING GAP
-- ============================================================

-- First inspect recent procedure execution logs.
-- A complete enterprise log should show StartedAt, EndedAt, Status, RowsAffected, and Message.
SELECT TOP 20
    ExecutionLogID,
    ProcedureName,
    Status,
    RowsAffected,
    Message,
    StartedAt,
    EndedAt,
    DATEDIFF(MILLISECOND, StartedAt, COALESCE(EndedAt, SYSUTCDATETIME())) AS DurationMs,
    CASE
        WHEN EndedAt IS NULL AND Status <> 'Started' THEN 'Check incomplete end timestamp'
        WHEN Status = 'Failed' THEN 'Review m3.ErrorLog for details'
        WHEN Status = 'Succeeded' THEN 'Completed successfully'
        ELSE 'Review log completeness'
    END AS DiagnosticNote
FROM m3.ProcedureExecutionLog
ORDER BY ExecutionLogID DESC;
GO

-- Force a controlled failure in the older dynamic validation procedure.
-- The procedure throws because the table does not exist.
-- Use TRY/CATCH so the lab script keeps running.
BEGIN TRY
    DECLARE @BadRunID INT;

    EXEC m3.usp_RunDataQualityChecks
        @TargetSchema = 'm3',
        @TargetTable = 'MissingTable',
        @RuleSetName = 'RegulatorySubmissionBasic',
        @RunID = @BadRunID OUTPUT;
END TRY
BEGIN CATCH
    -- ERROR_MESSAGE() returns the readable error text from the failed statement.
    SELECT
        'Expected failure for log diagnosis' AS Result,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Re-check logs and errors.
-- If the failed procedure did not write a Failed log row, that is a logging gap.
SELECT TOP 20
    ExecutionLogID,
    ProcedureName,
    Status,
    RowsAffected,
    Message,
    StartedAt,
    EndedAt
FROM m3.ProcedureExecutionLog
WHERE ProcedureName LIKE 'm3.usp_Run%'
ORDER BY ExecutionLogID DESC;
GO

SELECT TOP 10
    ErrorTime,
    ProcedureName,
    ErrorNumber,
    ErrorMessage
FROM m3.ErrorLog
ORDER BY ErrorLogID DESC;
GO

-- ============================================================
-- 3. DEVELOP AN ENTERPRISE VALIDATION STORED PROCEDURE
-- ============================================================

-- This procedure is intentionally set-based and heavily commented.
-- It validates the staging table, creates a ValidationRun row, creates
-- ValidationViolation rows, logs execution success/failure, and prints
-- diagnostic error details in the CATCH block.
CREATE OR ALTER PROCEDURE m3.usp_RunEnterpriseStagingValidation
    @RuleSetName VARCHAR(50) = 'RegulatorySubmissionBasic',
    @StopOnHighSeverity BIT = 0,
    @RunID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ExecutionLogID INT,
        @TotalViolations INT = 0,
        @HighSeverityViolations INT = 0,
        @ReturnCode INT = 0;

    SET @RunID = NULL;

    -- Start logging before validation checks.
    -- This fixes the common gap where early failures are not logged.
    EXEC m3.usp_LogProcedureExecution
        @ProcedureName = 'm3.usp_RunEnterpriseStagingValidation',
        @Status = 'Started',
        @RowsAffected = 0,
        @Message = 'Enterprise staging validation started',
        @ExecutionLogID = @ExecutionLogID OUTPUT;

    BEGIN TRY
        -- Guard clause: make sure the configured rule set exists.
        IF NOT EXISTS (
            SELECT 1
            FROM m3.ValidationRule
            WHERE RuleSetName = @RuleSetName
              AND TargetSchema = 'm3'
              AND TargetTable = 'StagingRegulatorySubmissions'
              AND IsActive = 1
        )
        BEGIN
            THROW 53001, 'No active validation rules found for enterprise staging validation.', 1;
        END;

        -- Create one run header row so every violation can be linked to a run.
        INSERT INTO m3.ValidationRun
            (RuleSetName, TargetSchema, TargetTable, Status)
        VALUES
            (@RuleSetName, 'm3', 'StagingRegulatorySubmissions', 'Running');

        SET @RunID = SCOPE_IDENTITY();

        -- Rule: InstitutionCode is required.
        INSERT INTO m3.ValidationViolation
            (RunID, RuleID, SourceKey, Severity, ViolationMessage)
        SELECT
            @RunID,
            vr.RuleID,
            CAST(s.SubmissionID AS VARCHAR(50)),
            vr.Severity,
            CONCAT(vr.RuleName, ': InstitutionCode is required')
        FROM m3.StagingRegulatorySubmissions AS s
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleSetName = @RuleSetName
           AND vr.TargetSchema = 'm3'
           AND vr.TargetTable = 'StagingRegulatorySubmissions'
           AND vr.ColumnName = 'InstitutionCode'
           AND vr.RuleType = 'NOT_NULL'
           AND vr.IsActive = 1
        WHERE s.InstitutionCode IS NULL;

        -- Rule: ReportingPeriod is required.
        INSERT INTO m3.ValidationViolation
            (RunID, RuleID, SourceKey, Severity, ViolationMessage)
        SELECT
            @RunID,
            vr.RuleID,
            CAST(s.SubmissionID AS VARCHAR(50)),
            vr.Severity,
            CONCAT(vr.RuleName, ': ReportingPeriod is required')
        FROM m3.StagingRegulatorySubmissions AS s
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleSetName = @RuleSetName
           AND vr.TargetSchema = 'm3'
           AND vr.TargetTable = 'StagingRegulatorySubmissions'
           AND vr.ColumnName = 'ReportingPeriod'
           AND vr.RuleType = 'NOT_NULL'
           AND vr.IsActive = 1
        WHERE s.ReportingPeriod IS NULL;

        -- Rule: TotalAssets must be non-negative.
        INSERT INTO m3.ValidationViolation
            (RunID, RuleID, SourceKey, Severity, ViolationMessage)
        SELECT
            @RunID,
            vr.RuleID,
            CAST(s.SubmissionID AS VARCHAR(50)),
            vr.Severity,
            CONCAT(vr.RuleName, ': TotalAssets ', CONVERT(VARCHAR(50), s.TotalAssets), ' is below minimum')
        FROM m3.StagingRegulatorySubmissions AS s
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleSetName = @RuleSetName
           AND vr.TargetSchema = 'm3'
           AND vr.TargetTable = 'StagingRegulatorySubmissions'
           AND vr.ColumnName = 'TotalAssets'
           AND vr.RuleType = 'MIN_VALUE'
           AND vr.IsActive = 1
        WHERE s.TotalAssets IS NOT NULL
          AND s.TotalAssets < vr.MinNumericValue;

        -- Rule: CapitalAdequacyRatio minimum.
        INSERT INTO m3.ValidationViolation
            (RunID, RuleID, SourceKey, Severity, ViolationMessage)
        SELECT
            @RunID,
            vr.RuleID,
            CAST(s.SubmissionID AS VARCHAR(50)),
            vr.Severity,
            CONCAT(vr.RuleName, ': CapitalAdequacyRatio ', CONVERT(VARCHAR(50), s.CapitalAdequacyRatio), ' is below minimum')
        FROM m3.StagingRegulatorySubmissions AS s
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleSetName = @RuleSetName
           AND vr.TargetSchema = 'm3'
           AND vr.TargetTable = 'StagingRegulatorySubmissions'
           AND vr.ColumnName = 'CapitalAdequacyRatio'
           AND vr.RuleType = 'MIN_VALUE'
           AND vr.IsActive = 1
        WHERE s.CapitalAdequacyRatio IS NOT NULL
          AND s.CapitalAdequacyRatio < vr.MinNumericValue;

        -- Rule: LiquidityCoverageRatio minimum.
        INSERT INTO m3.ValidationViolation
            (RunID, RuleID, SourceKey, Severity, ViolationMessage)
        SELECT
            @RunID,
            vr.RuleID,
            CAST(s.SubmissionID AS VARCHAR(50)),
            vr.Severity,
            CONCAT(vr.RuleName, ': LiquidityCoverageRatio ', CONVERT(VARCHAR(50), s.LiquidityCoverageRatio), ' is below minimum')
        FROM m3.StagingRegulatorySubmissions AS s
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleSetName = @RuleSetName
           AND vr.TargetSchema = 'm3'
           AND vr.TargetTable = 'StagingRegulatorySubmissions'
           AND vr.ColumnName = 'LiquidityCoverageRatio'
           AND vr.RuleType = 'MIN_VALUE'
           AND vr.IsActive = 1
        WHERE s.LiquidityCoverageRatio IS NOT NULL
          AND s.LiquidityCoverageRatio < vr.MinNumericValue;

        -- Rule: SubmissionStatus must be recognised.
        INSERT INTO m3.ValidationViolation
            (RunID, RuleID, SourceKey, Severity, ViolationMessage)
        SELECT
            @RunID,
            vr.RuleID,
            CAST(s.SubmissionID AS VARCHAR(50)),
            vr.Severity,
            CONCAT(vr.RuleName, ': status ', COALESCE(s.SubmissionStatus, 'NULL'), ' is not recognised')
        FROM m3.StagingRegulatorySubmissions AS s
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleSetName = @RuleSetName
           AND vr.TargetSchema = 'm3'
           AND vr.TargetTable = 'StagingRegulatorySubmissions'
           AND vr.ColumnName = 'SubmissionStatus'
           AND vr.RuleType = 'STATUS_IN'
           AND vr.IsActive = 1
        WHERE s.SubmissionStatus IS NULL
           OR s.SubmissionStatus NOT IN ('Received', 'Validated', 'Rejected', 'Submitted');

        -- Rule: InstitutionCode must exist in m3.Institutions.
        INSERT INTO m3.ValidationViolation
            (RunID, RuleID, SourceKey, Severity, ViolationMessage)
        SELECT
            @RunID,
            vr.RuleID,
            CAST(s.SubmissionID AS VARCHAR(50)),
            vr.Severity,
            CONCAT(vr.RuleName, ': institution ', s.InstitutionCode, ' is not in m3.Institutions')
        FROM m3.StagingRegulatorySubmissions AS s
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleSetName = @RuleSetName
           AND vr.TargetSchema = 'm3'
           AND vr.TargetTable = 'StagingRegulatorySubmissions'
           AND vr.ColumnName = 'InstitutionCode'
           AND vr.RuleType = 'FK_INSTITUTION'
           AND vr.IsActive = 1
        WHERE s.InstitutionCode IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM m3.Institutions AS i
              WHERE i.InstitutionCode = s.InstitutionCode
          );

        -- Summarise violations for the run.
        SELECT
            @TotalViolations = COUNT(*),
            @HighSeverityViolations = COALESCE(SUM(CASE WHEN Severity = 'High' THEN 1 ELSE 0 END), 0)
        FROM m3.ValidationViolation
        WHERE RunID = @RunID;

        -- Optional enterprise gate:
        -- Return 2 when high-severity issues should stop downstream processing.
        SET @ReturnCode =
            CASE
                WHEN @StopOnHighSeverity = 1 AND @HighSeverityViolations > 0 THEN 2
                ELSE 0
            END;

        UPDATE m3.ValidationRun
        SET
            CompletedAt = SYSUTCDATETIME(),
            Status = CASE
                WHEN @TotalViolations = 0 THEN 'Passed'
                WHEN @ReturnCode = 2 THEN 'Failed Quality Gate'
                ELSE 'Completed'
            END,
            TotalViolations = @TotalViolations
        WHERE RunID = @RunID;

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_RunEnterpriseStagingValidation',
            @Status = 'Succeeded',
            @RowsAffected = @TotalViolations,
            @Message = CONCAT('Enterprise validation completed. Total violations: ', @TotalViolations, ', High severity: ', @HighSeverityViolations),
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        SELECT
            @RunID AS RunID,
            @TotalViolations AS TotalViolations,
            @HighSeverityViolations AS HighSeverityViolations,
            @ReturnCode AS ReturnCode;

        SELECT
            vv.SourceKey,
            vr.RuleName,
            vv.Severity,
            vv.ViolationMessage,
            vv.CreatedAt
        FROM m3.ValidationViolation AS vv
        INNER JOIN m3.ValidationRule AS vr
            ON vr.RuleID = vv.RuleID
        WHERE vv.RunID = @RunID
        ORDER BY
            CASE vv.Severity WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
            vv.SourceKey,
            vr.RuleName;

        RETURN @ReturnCode;
    END TRY
    BEGIN CATCH
        -- TRY...CATCH gives us structured error handling.
        -- These built-in error functions are only available inside CATCH:
        -- ERROR_MESSAGE() returns the readable error text.
        -- ERROR_NUMBER() returns the SQL Server error number.
        -- ERROR_SEVERITY() returns how serious the error is.
        -- ERROR_STATE() returns the error state code.
        -- ERROR_LINE() returns the line where the error occurred.
        -- ERROR_PROCEDURE() returns the stored procedure or trigger name, when available.

        -- PRINT statements help during guided practice and live debugging.
        PRINT 'An error occurred.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(20));
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');

        -- Store the same error details in m3.ErrorLog for later diagnosis.
        INSERT INTO m3.ErrorLog
            (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
        VALUES
            ('m3.usp_RunEnterpriseStagingValidation', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

        IF @RunID IS NOT NULL
        BEGIN
            UPDATE m3.ValidationRun
            SET
                CompletedAt = SYSUTCDATETIME(),
                Status = 'Failed'
            WHERE RunID = @RunID;
        END;

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_RunEnterpriseStagingValidation',
            @Status = 'Failed',
            @RowsAffected = 0,
            @Message = 'Enterprise validation failed; see m3.ErrorLog',
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        SET @RunID = COALESCE(@RunID, 0);
        RETURN 1;
    END CATCH;
END;
GO

-- ============================================================
-- 4. RUN THE ENTERPRISE VALIDATION PROCEDURE
-- ============================================================

DECLARE @RunID INT;
DECLARE @ReturnCode INT;

EXEC @ReturnCode = m3.usp_RunEnterpriseStagingValidation
    @RuleSetName = 'RegulatorySubmissionBasic',
    @StopOnHighSeverity = 1,
    @RunID = @RunID OUTPUT;

SELECT
    @ReturnCode AS ReturnCode,
    @RunID AS RunID;
GO

-- ============================================================
-- 5. REVIEW VALIDATION RUN SUMMARY
-- ============================================================

SELECT TOP 5
    RunID,
    RuleSetName,
    TargetSchema,
    TargetTable,
    Status,
    TotalViolations,
    StartedAt,
    CompletedAt,
    ExecutedBy
FROM m3.ValidationRun
ORDER BY RunID DESC;
GO

-- ============================================================
-- 6. REVIEW VIOLATIONS BY SEVERITY AND RULE
-- ============================================================

SELECT
    vv.RunID,
    vr.RuleName,
    vv.Severity,
    COUNT(*) AS ViolationCount
FROM m3.ValidationViolation AS vv
INNER JOIN m3.ValidationRule AS vr
    ON vv.RuleID = vr.RuleID
GROUP BY
    vv.RunID,
    vr.RuleName,
    vv.Severity
ORDER BY
    vv.RunID DESC,
    CASE vv.Severity WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
    vr.RuleName;
GO

-- ============================================================
-- 7. SHOW DETAILED VIOLATIONS FOR THE LATEST RUN
-- ============================================================

DECLARE @LatestRunID INT = (
    SELECT MAX(RunID)
    FROM m3.ValidationRun
);

SELECT
    vv.SourceKey,
    vr.RuleName,
    vv.Severity,
    vv.ViolationMessage,
    vv.CreatedAt
FROM m3.ValidationViolation AS vv
INNER JOIN m3.ValidationRule AS vr
    ON vv.RuleID = vr.RuleID
WHERE vv.RunID = @LatestRunID
ORDER BY
    CASE vv.Severity WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
    vv.SourceKey,
    vr.RuleName;
GO

-- ============================================================
-- 8. REVIEW EXECUTION AND ERROR LOGS
-- ============================================================

SELECT TOP 20
    ExecutionLogID,
    ProcedureName,
    Status,
    RowsAffected,
    Message,
    StartedAt,
    EndedAt,
    DATEDIFF(MILLISECOND, StartedAt, COALESCE(EndedAt, SYSUTCDATETIME())) AS DurationMs
FROM m3.ProcedureExecutionLog
ORDER BY ExecutionLogID DESC;
GO

SELECT TOP 10
    ErrorTime,
    ProcedureName,
    ErrorNumber,
    ErrorMessage
FROM m3.ErrorLog
ORDER BY ErrorLogID DESC;
GO
