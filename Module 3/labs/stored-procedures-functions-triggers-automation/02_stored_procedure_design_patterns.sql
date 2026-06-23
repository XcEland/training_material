-- ============================================================
-- MODULE 3 LAB
-- FILE 02: STORED PROCEDURE DESIGN PATTERNS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A stored procedure is a saved SQL program that can be executed again and again.
-- Start with a normal query, then turn it into a reusable procedure.
-- This lab builds up slowly: queries, parameters, variables, IF/ELSE,
-- null handling, reports, TRY/CATCH, output parameters, return codes, and logging.

-- Common input parameter examples:
-- @Country
-- @InstitutionCode
-- @StartPeriod
-- @EndPeriod
-- @ReportType
-- @UploadedBy

-- ============================================================
-- 1. START WITH A NORMAL QUERY
-- ============================================================

-- Step 1: Write a query.
-- For Lesotho institutions, find the total institutions and average capital adequacy.
SELECT
    COUNT(DISTINCT i.InstitutionCode) AS TotalInstitutions,
    AVG(s.CapitalAdequacyRatio) AS AvgCapitalAdequacyRatio
FROM m3.Institutions AS i
LEFT JOIN m3.RegulatorySubmissions AS s
    ON s.InstitutionCode = i.InstitutionCode
WHERE i.Country = 'Lesotho';
GO

-- ============================================================
-- 2. TURN THE QUERY INTO A BASIC STORED PROCEDURE
-- ============================================================

-- Step 2: Create a stored procedure.
-- This version has no parameters, so it always reports on Lesotho.
CREATE OR ALTER PROCEDURE m3.usp_GetCountrySubmissionStats
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(DISTINCT i.InstitutionCode) AS TotalInstitutions,
        AVG(s.CapitalAdequacyRatio) AS AvgCapitalAdequacyRatio
    FROM m3.Institutions AS i
    LEFT JOIN m3.RegulatorySubmissions AS s
        ON s.InstitutionCode = i.InstitutionCode
    WHERE i.Country = 'Lesotho';
END;
GO

-- Step 3: Execute it.
EXEC m3.usp_GetCountrySubmissionStats;
GO

-- ============================================================
-- 3. ADD AN INPUT PARAMETER
-- ============================================================

-- This version accepts @Country.
-- Default value means the procedure uses 'Lesotho' when no country is passed.
CREATE OR ALTER PROCEDURE m3.usp_GetCountrySubmissionStats
    @Country VARCHAR(50) = 'Lesotho'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(DISTINCT i.InstitutionCode) AS TotalInstitutions,
        AVG(s.CapitalAdequacyRatio) AS AvgCapitalAdequacyRatio
    FROM m3.Institutions AS i
    LEFT JOIN m3.RegulatorySubmissions AS s
        ON s.InstitutionCode = i.InstitutionCode
    WHERE i.Country = @Country;
END;
GO

-- Execute with an explicit parameter.
EXEC m3.usp_GetCountrySubmissionStats
    @Country = 'South Africa';
GO

-- Execute with the default parameter value.
EXEC m3.usp_GetCountrySubmissionStats;
GO

-- ============================================================
-- 4. RETURN MULTIPLE RESULT SETS
-- ============================================================

-- A procedure can run more than one SELECT.
-- Result set 1: institution statistics.
-- Result set 2: submission totals.
CREATE OR ALTER PROCEDURE m3.usp_GetCountrySubmissionStats
    @Country VARCHAR(50) = 'Lesotho'
AS
BEGIN
    SET NOCOUNT ON;

    -- Report 1: institution-level summary.
    SELECT
        COUNT(DISTINCT i.InstitutionCode) AS TotalInstitutions,
        AVG(s.CapitalAdequacyRatio) AS AvgCapitalAdequacyRatio
    FROM m3.Institutions AS i
    LEFT JOIN m3.RegulatorySubmissions AS s
        ON s.InstitutionCode = i.InstitutionCode
    WHERE i.Country = @Country;

    -- Report 2: submission totals for the same country.
    SELECT
        COUNT(s.SubmissionID) AS TotalSubmissions,
        SUM(s.TotalAssets) AS TotalAssets,
        SUM(s.TotalLiabilities) AS TotalLiabilities
    FROM m3.RegulatorySubmissions AS s
    INNER JOIN m3.Institutions AS i
        ON i.InstitutionCode = s.InstitutionCode
    WHERE i.Country = @Country;
END;
GO

EXEC m3.usp_GetCountrySubmissionStats
    @Country = 'Lesotho';
GO

-- ============================================================
-- 5. USE VARIABLES INSIDE A STORED PROCEDURE
-- ============================================================

-- Variables hold intermediate values inside the procedure.
-- PRINT is useful for simple teaching/debugging messages.
CREATE OR ALTER PROCEDURE m3.usp_GetCountrySubmissionStats
    @Country VARCHAR(50) = 'Lesotho'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalInstitutions INT;
    DECLARE @AvgCapitalAdequacyRatio DECIMAL(9,4);

    SELECT
        @TotalInstitutions = COUNT(DISTINCT i.InstitutionCode),
        @AvgCapitalAdequacyRatio = AVG(s.CapitalAdequacyRatio)
    FROM m3.Institutions AS i
    LEFT JOIN m3.RegulatorySubmissions AS s
        ON s.InstitutionCode = i.InstitutionCode
    WHERE i.Country = @Country;

    PRINT CONCAT('Total institutions from ', @Country, ': ', @TotalInstitutions);
    PRINT CONCAT('Average capital adequacy from ', @Country, ': ', COALESCE(CAST(@AvgCapitalAdequacyRatio AS VARCHAR(30)), 'N/A'));

    SELECT
        COUNT(s.SubmissionID) AS TotalSubmissions,
        SUM(s.TotalAssets) AS TotalAssets,
        SUM(s.TotalLiabilities) AS TotalLiabilities
    FROM m3.RegulatorySubmissions AS s
    INNER JOIN m3.Institutions AS i
        ON i.InstitutionCode = s.InstitutionCode
    WHERE i.Country = @Country;
END;
GO

EXEC m3.usp_GetCountrySubmissionStats
    @Country = 'Lesotho';
GO

-- ============================================================
-- 6. CONTROL STRUCTURES AND BASIC PARAMETER VALIDATION
-- ============================================================

-- IF/ELSE lets a procedure make decisions.
-- This procedure checks that the country exists before running the report.
CREATE OR ALTER PROCEDURE m3.usp_ListSubmissionsByCountry
    @Country VARCHAR(50) = 'Lesotho'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM m3.Institutions
        WHERE Country = @Country
    )
    BEGIN
        PRINT CONCAT('No institutions found for country: ', @Country);
        RETURN;
    END;

    SELECT
        i.Country,
        i.InstitutionCode,
        i.InstitutionName,
        s.ReportingPeriod,
        s.ReportType,
        s.TotalAssets,
        s.TotalLiabilities,
        s.SubmissionStatus
    FROM m3.Institutions AS i
    INNER JOIN m3.RegulatorySubmissions AS s
        ON s.InstitutionCode = i.InstitutionCode
    WHERE i.Country = @Country
    ORDER BY
        i.InstitutionCode,
        s.ReportingPeriod;
END;
GO

EXEC m3.usp_ListSubmissionsByCountry
    @Country = 'Lesotho';
GO

EXEC m3.usp_ListSubmissionsByCountry
    @Country = 'Unknown Country';
GO

-- ============================================================
-- 7. CLEAN NULL VALUES IN STAGING DATA
-- ============================================================

-- Data cleaning procedures are common in ETL and validation work.
-- This example only cleans safe defaults in the staging table.
-- It does not change the main regulatory submissions table.
CREATE OR ALTER PROCEDURE m3.usp_CleanStagingSubmissionNulls
    @DefaultStatus VARCHAR(20) = 'Received'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsCleaned INT = 0;

    -- Clean missing status values.
    IF EXISTS (
        SELECT 1
        FROM m3.StagingRegulatorySubmissions
        WHERE SubmissionStatus IS NULL
    )
    BEGIN
        UPDATE m3.StagingRegulatorySubmissions
        SET SubmissionStatus = @DefaultStatus
        WHERE SubmissionStatus IS NULL;

        SET @RowsCleaned = @RowsCleaned + @@ROWCOUNT;
    END
    ELSE
    BEGIN
        PRINT 'No NULL SubmissionStatus values found.';
    END;

    -- Clean missing submitted dates.
    IF EXISTS (
        SELECT 1
        FROM m3.StagingRegulatorySubmissions
        WHERE SubmittedAt IS NULL
    )
    BEGIN
        UPDATE m3.StagingRegulatorySubmissions
        SET SubmittedAt = SYSUTCDATETIME()
        WHERE SubmittedAt IS NULL;

        SET @RowsCleaned = @RowsCleaned + @@ROWCOUNT;
    END
    ELSE
    BEGIN
        PRINT 'No NULL SubmittedAt values found.';
    END;

    SELECT
        @RowsCleaned AS RowsCleaned;
END;
GO

EXEC m3.usp_CleanStagingSubmissionNulls;
GO

-- ============================================================
-- 8. REPORT PROCEDURE WITH NULL HANDLING
-- ============================================================

-- COALESCE handles NULL values at report time.
-- Here, NULL capital adequacy is displayed as 0 only in the report output.
CREATE OR ALTER PROCEDURE m3.usp_GetCountryRiskReport
    @Country VARCHAR(50) = 'Lesotho',
    @MinimumCapitalAdequacy DECIMAL(9,4) = 10.0000
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimumCapitalAdequacy < 0
    BEGIN
        THROW 50001, 'Minimum capital adequacy cannot be negative.', 1;
    END;

    SELECT
        i.Country,
        i.InstitutionCode,
        i.InstitutionName,
        s.ReportingPeriod,
        s.ReportType,
        COALESCE(s.CapitalAdequacyRatio, 0) AS CapitalAdequacyRatioForReport,
        CASE
            WHEN s.CapitalAdequacyRatio IS NULL THEN 'Not Reported'
            WHEN s.CapitalAdequacyRatio < @MinimumCapitalAdequacy THEN 'Below Minimum'
            ELSE 'Meets Minimum'
        END AS CapitalAdequacyStatus
    FROM m3.Institutions AS i
    INNER JOIN m3.RegulatorySubmissions AS s
        ON s.InstitutionCode = i.InstitutionCode
    WHERE i.Country = @Country
    ORDER BY
        i.InstitutionCode,
        s.ReportingPeriod;
END;
GO

EXEC m3.usp_GetCountryRiskReport
    @Country = 'Lesotho',
    @MinimumCapitalAdequacy = 10.0000;
GO

-- ============================================================
-- 9. REUSABLE EXECUTION LOGGING PROCEDURE
-- ============================================================

-- This helper procedure starts or completes a log row.
-- If @ExecutionLogID is NULL, it inserts a new log row.
-- If @ExecutionLogID has a value, it updates that log row.
CREATE OR ALTER PROCEDURE m3.usp_LogProcedureExecution
    @ProcedureName SYSNAME,
    @Status VARCHAR(20),
    @RowsAffected INT = NULL,
    @Message NVARCHAR(1000) = NULL,
    @ExecutionLogID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @ExecutionLogID IS NULL
    BEGIN
        INSERT INTO m3.ProcedureExecutionLog
            (ProcedureName, Status, RowsAffected, Message)
        VALUES
            (@ProcedureName, @Status, @RowsAffected, @Message);

        SET @ExecutionLogID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE m3.ProcedureExecutionLog
        SET
            EndedAt = SYSUTCDATETIME(),
            Status = @Status,
            RowsAffected = @RowsAffected,
            Message = @Message
        WHERE ExecutionLogID = @ExecutionLogID;
    END;
END;
GO

-- ============================================================
-- 10. FULL PROCEDURE: OPTIONAL PARAMETERS, OUTPUT, RETURN CODE, TRY/CATCH
-- ============================================================

-- This is the fuller pattern students build toward.
-- Input parameters filter the report.
-- The output parameter returns the number of rows.
-- RETURN 0 means success. RETURN 1 means failure.
CREATE OR ALTER PROCEDURE m3.usp_GetInstitutionSubmissionSummary
    @InstitutionCode VARCHAR(20) = NULL,
    @StartPeriod DATE = NULL,
    @EndPeriod DATE = NULL,
    @RowsReturned INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionLogID INT;

    EXEC m3.usp_LogProcedureExecution
        @ProcedureName = 'm3.usp_GetInstitutionSubmissionSummary',
        @Status = 'Started',
        @Message = 'Summary procedure started',
        @ExecutionLogID = @ExecutionLogID OUTPUT;

    BEGIN TRY
        IF @StartPeriod IS NOT NULL
           AND @EndPeriod IS NOT NULL
           AND @StartPeriod > @EndPeriod
        BEGIN
            THROW 50002, 'Start period cannot be after end period.', 1;
        END;

        SELECT
            i.InstitutionCode,
            i.InstitutionName,
            s.ReportType,
            COUNT(*) AS SubmissionCount,
            SUM(s.TotalAssets) AS TotalAssets,
            SUM(s.TotalLiabilities) AS TotalLiabilities,
            AVG(s.CapitalAdequacyRatio) AS AvgCapitalAdequacyRatio,
            AVG(s.LiquidityCoverageRatio) AS AvgLiquidityCoverageRatio
        FROM m3.RegulatorySubmissions AS s
        INNER JOIN m3.Institutions AS i
            ON s.InstitutionCode = i.InstitutionCode
        WHERE (@InstitutionCode IS NULL OR s.InstitutionCode = @InstitutionCode)
          AND (@StartPeriod IS NULL OR s.ReportingPeriod >= @StartPeriod)
          AND (@EndPeriod IS NULL OR s.ReportingPeriod <= @EndPeriod)
        GROUP BY
            i.InstitutionCode,
            i.InstitutionName,
            s.ReportType
        ORDER BY
            i.InstitutionCode,
            s.ReportType;

        SET @RowsReturned = @@ROWCOUNT;

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_GetInstitutionSubmissionSummary',
            @Status = 'Succeeded',
            @RowsAffected = @RowsReturned,
            @Message = 'Summary procedure completed',
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        RETURN 0;
    END TRY
    BEGIN CATCH
        INSERT INTO m3.ErrorLog
            (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
        VALUES
            ('m3.usp_GetInstitutionSubmissionSummary', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

        -- TRY...CATCH gives us structured error handling.
        -- ERROR_MESSAGE() returns readable text.
        -- ERROR_NUMBER() returns the SQL Server error number.
        -- ERROR_SEVERITY() returns how serious the error is.
        -- ERROR_STATE() returns the error state code.
        -- ERROR_LINE() returns the line where the error occurred.
        -- ERROR_PROCEDURE() returns the procedure name, when available.
        -- Diagnostic messages help during guided practice and debugging.
        PRINT 'An error occurred.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(20));
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_GetInstitutionSubmissionSummary',
            @Status = 'Failed',
            @RowsAffected = 0,
            @Message = 'Summary procedure failed; see m3.ErrorLog',
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        SET @RowsReturned = 0;
        RETURN 1;
    END CATCH;
END;
GO

-- Execute the full procedure and capture both return styles.
DECLARE @RowsReturned INT;
DECLARE @ReturnCode INT;

EXEC @ReturnCode = m3.usp_GetInstitutionSubmissionSummary
    @InstitutionCode = NULL,
    @StartPeriod = '2026-01-01',
    @EndPeriod = '2026-12-31',
    @RowsReturned = @RowsReturned OUTPUT;

SELECT
    @ReturnCode AS ReturnCode,
    @RowsReturned AS RowsReturned;
GO

-- Review execution logs.
SELECT TOP 10
    ExecutionLogID,
    ProcedureName,
    Status,
    RowsAffected,
    Message,
    StartedAt,
    EndedAt
FROM m3.ProcedureExecutionLog
ORDER BY ExecutionLogID DESC;
GO
