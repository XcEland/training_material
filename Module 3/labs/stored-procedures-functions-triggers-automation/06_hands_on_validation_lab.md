-- ============================================================
-- MODULE 3 HANDS-ON LAB
-- FILE 06: AUTOMATED DATA VALIDATION LAB - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- m3.StagingRegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.ValidationRule fields: RuleID, RuleSetName, TargetSchema, TargetTable, RuleName, ColumnName, RuleType, MinNumericValue, MaxNumericValue, Severity, IsActive
-- m3.ValidationRun fields: RunID, RuleSetName, TargetSchema, TargetTable, StartedAt, CompletedAt, Status, TotalViolations, ExecutedBy
-- m3.ValidationViolation fields: ViolationID, RunID, RuleID, SourceKey, Severity, ViolationMessage, CreatedAt
-- m3.ProcedureExecutionLog fields: ExecutionLogID, ProcedureName, StartedAt, EndedAt, Status, RowsAffected, Message
-- m3.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage

-- Procedures used:
-- m3.usp_RunDataQualityChecks
-- m3.usp_LogProcedureExecution
-- m3.usp_RunEnterpriseStagingValidation

-- Worksheet:
-- validation_lab_worksheet.md

-- Notes:
-- This lab combines Module 3 concepts into one validation exercise.
-- Learners should interpret execution logs, diagnose gaps, build a full validation procedure,
-- and record validation parameters, rules, violations, logs, and improvements in the worksheet.

-- 1. Review staging data with intentional issues.
-- Source table: m3.StagingRegulatorySubmissions.
-- Return SubmissionID, institution, period, report type, numeric metrics, and status.
-- ORDER BY note: sort by SubmissionID.

-- 2. Add one more lab issue.
-- Insert an RCH clearing house row with LiquidityCoverageRatio below 100.
-- This creates another validation issue for the run.
-- Use IF NOT EXISTS so the same lab issue is not inserted repeatedly.

-- 3. Interpret execution logs.
-- Query m3.ProcedureExecutionLog.
-- Return duration using DATEDIFF.
-- Add a DiagnosticNote CASE expression.
-- Look for missing EndedAt, Failed status, and unclear messages.

-- 4. Diagnose an error-handling gap.
-- Call m3.usp_RunDataQualityChecks with @TargetTable = 'MissingTable'.
-- Wrap it in TRY/CATCH so the script continues.
-- Re-check m3.ProcedureExecutionLog and m3.ErrorLog.
-- If there is no Failed log row, explain that this is a logging gap.

-- 5. Develop m3.usp_RunEnterpriseStagingValidation.
-- Parameters:
-- @RuleSetName VARCHAR(50) = 'RegulatorySubmissionBasic'
-- @StopOnHighSeverity BIT = 0
-- @RunID INT OUTPUT
-- Start execution logging before validation checks.
-- Use TRY/CATCH around all validation logic.
-- Create one m3.ValidationRun row with Status = 'Running'.
-- Insert validation violations for each rule:
-- InstitutionCode is required.
-- ReportingPeriod is required.
-- TotalAssets must be non-negative.
-- CapitalAdequacyRatio minimum.
-- LiquidityCoverageRatio minimum.
-- SubmissionStatus must be recognised.
-- InstitutionCode must exist in m3.Institutions.
-- Count total violations and high-severity violations.
-- Update m3.ValidationRun with final status and total violations.
-- Log success to m3.ProcedureExecutionLog.
-- In CATCH, use T-SQL error functions:
-- ERROR_NUMBER() returns the SQL Server error number.
-- ERROR_MESSAGE() returns the readable error text.
-- ERROR_LINE() returns the line where the error occurred.
-- ERROR_PROCEDURE() returns the procedure or trigger name when available.
-- ERROR_SEVERITY() returns how serious the error is.
-- ERROR_STATE() returns the error state code.
-- In CATCH, PRINT diagnostic error details for live debugging.
-- In CATCH, insert the same details into m3.ErrorLog for later diagnosis.
-- In CATCH, update ValidationRun to Failed if a run was created.
-- In CATCH, log failure to m3.ProcedureExecutionLog.

-- 6. Run the enterprise validation procedure.
-- Declare @RunID and @ReturnCode.
-- Execute m3.usp_RunEnterpriseStagingValidation.
-- Use @StopOnHighSeverity = 1.
-- Return @ReturnCode and @RunID.

-- 7. Review validation run summary.
-- Source table: m3.ValidationRun.
-- Return latest run details.
-- ORDER BY note: sort newest first by RunID DESC.

-- 8. Review violations by severity and rule.
-- Join m3.ValidationViolation to m3.ValidationRule.
-- Group by RunID, RuleName, Severity.
-- ORDER BY note: sort High before Medium.

-- 9. Show detailed violations for the latest run.
-- Capture MAX(RunID) from m3.ValidationRun.
-- Return SourceKey, RuleName, Severity, ViolationMessage, CreatedAt.
-- ORDER BY note: sort by severity, source key, and rule name.

-- 10. Review execution and error logs.
-- Query m3.ProcedureExecutionLog newest first.
-- Query m3.ErrorLog newest first.

-- Practice tasks:

-- Practice 1. Add another validation rule.
-- Example: TotalLiabilities must be non-negative.
-- Insert the rule into m3.ValidationRule.

-- Practice 2. Run the enterprise validation procedure again.
-- Compare the new TotalViolations to the previous run.

-- Practice 3. Force a failure by using a wrong @RuleSetName.
-- Confirm m3.ErrorLog and m3.ProcedureExecutionLog both record the failure.

-- Practice 4. Complete validation_lab_worksheet.md.
-- Record RunID, total violations, high-risk rules, log findings, and one production improvement.
