-- ============================================================
-- MODULE 3 LAB
-- FILE 05: SECURE DYNAMIC SQL VALIDATION PROCEDURE - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- m3.StagingRegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.Institutions fields: InstitutionCode, InstitutionName, InstitutionType, Country, IsActive
-- m3.ValidationRule fields: RuleID, RuleSetName, TargetSchema, TargetTable, RuleName, ColumnName, RuleType, MinNumericValue, MaxNumericValue, Severity, IsActive
-- m3.ValidationRun fields: RunID, RuleSetName, TargetSchema, TargetTable, StartedAt, CompletedAt, Status, TotalViolations, ExecutedBy
-- m3.ValidationViolation fields: ViolationID, RunID, RuleID, SourceKey, Severity, ViolationMessage, CreatedAt
-- m3.ProcedureExecutionLog fields: ExecutionLogID, ProcedureName, StartedAt, EndedAt, Status, RowsAffected, Message
-- m3.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage

-- Procedure name:
-- m3.usp_RunDataQualityChecks

-- Supporting procedure:
-- m3.usp_LogProcedureExecution

-- Preview validation configuration and staging data.
SELECT TOP 10 * FROM m3.ValidationRule ORDER BY RuleID;
SELECT TOP 10 * FROM m3.StagingRegulatorySubmissions ORDER BY SubmissionID;

-- Notes:
-- Dynamic SQL builds a SQL command as text before execution.
-- Use dynamic SQL only when object names or flexible rule logic must be generated.
-- QUOTENAME protects schema, table, and column names.
-- sp_executesql supports parameterized dynamic SQL.
-- Do not concatenate untrusted user values directly into dynamic SQL.

-- 1. Static validation query.
-- Count rows where InstitutionCode IS NULL in m3.StagingRegulatorySubmissions.
-- Use static SQL because the table and column names are known.

-- 2. Simple dynamic SQL example.
-- Declare @BasicSql NVARCHAR(MAX).
-- Assemble a SELECT COUNT query using QUOTENAME for schema and table name.
-- Execute the statement with sp_executesql.

-- 3. Parameterized dynamic SQL example.
-- Build the table name dynamically.
-- Pass SubmissionStatus as a parameter, not by direct string concatenation.

-- 4. Create procedure m3.usp_RunDataQualityChecks.
-- Input parameters:
-- @TargetSchema SYSNAME.
-- @TargetTable SYSNAME.
-- @RuleSetName VARCHAR(50).
-- Output parameter: @RunID INT OUTPUT.

-- 5. Declare working variables.
-- Full table name, rule fields, SQL text, total violations, and execution log ID.

-- 6. Validate target table.
-- Check sys.tables joined to sys.schemas.
-- Throw an error when the requested target table does not exist.

-- 7. Validate active rule configuration.
-- Check m3.ValidationRule for matching RuleSetName, TargetSchema, TargetTable, and IsActive = 1.
-- Throw an error when no active rules are found.

-- 8. Build a safe full table name.
-- Use QUOTENAME(@TargetSchema) + '.' + QUOTENAME(@TargetTable).

-- 9. Start procedure logging.
-- Execute m3.usp_LogProcedureExecution with Status = 'Started'.

-- 10. Create a validation run row.
-- Insert into m3.ValidationRun with Status = 'Running'.
-- Capture @RunID with SCOPE_IDENTITY().

-- 11. Loop through validation rules.
-- Use a LOCAL FAST_FORWARD cursor over active rules.
-- For each rule, build the correct validation SQL.

-- 12. Rule type logic.
-- NOT_NULL: column is required.
-- MIN_VALUE: numeric value must be greater than or equal to a configured minimum.
-- MAX_VALUE: numeric value must be less than or equal to a configured maximum.
-- STATUS_IN: status must be in the approved list.
-- FK_INSTITUTION: institution code must exist in m3.Institutions.

-- 13. Execute dynamic SQL safely.
-- Use sp_executesql.
-- Pass RunID, RuleID, Severity, RuleName, ColumnName, MinNumericValue, and MaxNumericValue as parameters.

-- 14. Complete the validation run.
-- Count violations for @RunID.
-- Update m3.ValidationRun with CompletedAt, Status, and TotalViolations.
-- Log success.
-- Return run summary and violation details.

-- 15. Handle errors.
-- Close and deallocate cursor if needed.
-- Insert error details into m3.ErrorLog.
-- Mark ValidationRun as Failed when applicable.
-- Log failed execution.
-- Re-throw the error.

-- 16. Execute the validation procedure.
-- Target schema: m3.
-- Target table: StagingRegulatorySubmissions.
-- Rule set: RegulatorySubmissionBasic.
-- Return @RunID.

-- Practice tasks:

-- Practice 1. Query active validation rules before running the procedure.
-- Return RuleName, ColumnName, RuleType, Severity.

-- Practice 2. Run the procedure and capture @RunID.
-- Query m3.ValidationRun for that RunID.

-- Practice 3. Review high-severity violations only.
-- Join m3.ValidationViolation to m3.ValidationRule.
-- Filter Severity = 'High'.
