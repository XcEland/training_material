-- ============================================================
-- MODULE 3 HANDS-ON LAB
-- FILE 06: AUTOMATED DATA VALIDATION LAB
-- ============================================================

USE TrainingDB;
GO

-- 1. Review the staging data with intentional issues.
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

-- 2. Add one more lab issue for the validation run.
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

-- 3. Run the automated validation procedure.
DECLARE @RunID INT;
DECLARE @ReturnCode INT;

EXEC @ReturnCode = m3.usp_RunDataQualityChecks
    @TargetSchema = 'm3',
    @TargetTable = 'StagingRegulatorySubmissions',
    @RuleSetName = 'RegulatorySubmissionBasic',
    @RunID = @RunID OUTPUT;

SELECT
    @ReturnCode AS ReturnCode,
    @RunID AS RunID;
GO

-- 4. Review validation run summary.
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

-- 5. Review violations by severity and rule.
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

-- 6. Show detailed violations for the latest run.
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

-- 7. Review execution and error logs.
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

SELECT TOP 10
    ErrorTime,
    ProcedureName,
    ErrorNumber,
    ErrorMessage
FROM m3.ErrorLog
ORDER BY ErrorLogID DESC;
GO
