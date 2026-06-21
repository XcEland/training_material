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

-- Procedure used:
-- m3.usp_RunDataQualityChecks

-- Worksheet:
-- validation_lab_worksheet.md

-- Notes:
-- This lab combines Module 3 concepts into one validation exercise.
-- Learners should record validation parameters, rules, violations, logs, and security checks in the worksheet.

-- 1. Review staging data with intentional issues.
-- Source table: m3.StagingRegulatorySubmissions.
-- Return SubmissionID, institution, period, report type, numeric metrics, and status.
-- ORDER BY note: sort by SubmissionID.

-- 2. Add one more lab issue.
-- Insert an RCH clearing house row with LiquidityCoverageRatio below 100.
-- This creates another validation issue for the run.
-- Use IF NOT EXISTS so the same lab issue is not inserted repeatedly.

-- 3. Run the automated validation procedure.
-- Declare @RunID and @ReturnCode.
-- Execute m3.usp_RunDataQualityChecks.
-- Parameters:
-- @TargetSchema = 'm3'.
-- @TargetTable = 'StagingRegulatorySubmissions'.
-- @RuleSetName = 'RegulatorySubmissionBasic'.
-- @RunID output.

-- 4. Review validation run summary.
-- Source table: m3.ValidationRun.
-- Return latest run details.
-- ORDER BY note: sort newest first by RunID DESC.

-- 5. Review violations by severity and rule.
-- Join m3.ValidationViolation to m3.ValidationRule.
-- Group by RunID, RuleName, Severity.
-- ORDER BY note: sort High before Medium.

-- 6. Show detailed violations for the latest run.
-- Capture MAX(RunID) from m3.ValidationRun.
-- Return SourceKey, RuleName, Severity, ViolationMessage, CreatedAt.
-- ORDER BY note: sort by severity, source key, and rule name.

-- 7. Review execution and error logs.
-- Query m3.ProcedureExecutionLog newest first.
-- Query m3.ErrorLog newest first.

-- Practice tasks:

-- Practice 1. Add another validation rule.
-- Example: TotalLiabilities must be non-negative.
-- Insert the rule into m3.ValidationRule.

-- Practice 2. Run the validation procedure again.
-- Compare the new TotalViolations to the previous run.

-- Practice 3. Complete validation_lab_worksheet.md.
-- Record RunID, total violations, high-risk rules, and one production improvement.
