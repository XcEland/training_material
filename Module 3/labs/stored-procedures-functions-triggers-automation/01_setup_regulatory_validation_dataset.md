-- ============================================================
-- MODULE 3 LAB
-- FILE 01: SETUP REGULATORY VALIDATION DATASET - LIVE CODING SCAFFOLD
-- ============================================================

-- Database:
-- TrainingDB

-- Schema:
-- m3

-- Tables and fields:
-- m3.Institutions fields: InstitutionCode, InstitutionName, InstitutionType, Country, IsActive
-- m3.RegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.StagingRegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.ProcedureExecutionLog fields: ExecutionLogID, ProcedureName, StartedAt, EndedAt, Status, RowsAffected, Message
-- m3.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage
-- m3.AuditLog fields: AuditID, TableName, OperationType, PrimaryKeyValue, ColumnName, OldValue, NewValue, ChangedBy, ChangedAt
-- m3.ValidationRule fields: RuleID, RuleSetName, TargetSchema, TargetTable, RuleName, ColumnName, RuleType, MinNumericValue, MaxNumericValue, Severity, IsActive
-- m3.ValidationRun fields: RunID, RuleSetName, TargetSchema, TargetTable, StartedAt, CompletedAt, Status, TotalViolations, ExecutedBy
-- m3.ValidationViolation fields: ViolationID, RunID, RuleID, SourceKey, Severity, ViolationMessage, CreatedAt

-- Relationships:
-- m3.RegulatorySubmissions.InstitutionCode references m3.Institutions.InstitutionCode
-- m3.ValidationViolation.RunID references m3.ValidationRun.RunID
-- m3.ValidationViolation.RuleID references m3.ValidationRule.RuleID

-- Objects created later:
-- m3.usp_CountRegulatorySubmissions
-- m3.usp_ListSubmissionsByInstitution
-- m3.usp_LogProcedureExecution
-- m3.usp_GetInstitutionSubmissionSummary
-- m3.usp_RunDataQualityChecks
-- m3.fn_CapitalAdequacyBand
-- m3.fn_SubmissionsByPeriod
-- m3.trg_StagingRegulatorySubmissions_InsertLog
-- m3.trg_RegulatorySubmissions_Audit
-- m3.trg_RegulatorySubmissions_BusinessRules

-- Notes:
-- This setup creates a regulatory reporting dataset for stored procedures, functions, triggers, and validation automation.
-- Staging rows intentionally include data quality issues.
-- Validation rules drive the automated validation procedure later in the lab.

-- 1. Create the database if it does not already exist.
-- Check with DB_ID('TrainingDB').

-- 2. Create the m3 schema if it does not already exist.
-- Use sys.schemas to check for schema name m3.

-- 3. Drop existing triggers, procedures, and functions.
-- Drop dependent automation objects before dropping tables.

-- 4. Drop existing tables in dependency order.
-- Drop ValidationViolation before ValidationRun and ValidationRule.
-- Drop child/staging/log tables before base reference tables.

-- 5. Create m3.Institutions.
-- InstitutionCode is the primary key.
-- IsActive uses BIT and defaults to 1.

-- 6. Create m3.RegulatorySubmissions.
-- SubmissionID is an identity primary key.
-- InstitutionCode links to m3.Institutions.
-- Regulatory metrics use DECIMAL for financial and ratio values.

-- 7. Create m3.StagingRegulatorySubmissions.
-- This table allows NULLs so invalid source records can be loaded and validated.

-- 8. Create logging tables.
-- ProcedureExecutionLog tracks procedure start/end status.
-- ErrorLog stores TRY/CATCH error details.
-- AuditLog stores trigger-generated change history.

-- 9. Create validation tables.
-- ValidationRule stores configurable checks.
-- ValidationRun stores one execution of a validation rule set.
-- ValidationViolation stores row-level validation failures.

-- 10. Insert reference institutions and valid regulatory submissions.
-- Include central bank, commercial bank, microfinance, payment provider, and clearing house examples.

-- 11. Insert staging submissions with known data quality issues.
-- Include missing institution, invalid institution, missing period, negative assets, low ratios, and invalid status.

-- 12. Insert validation rules.
-- Rule types: NOT_NULL, MIN_VALUE, STATUS_IN, FK_INSTITUTION.

-- 13. Confirm row counts.
-- Count rows in Institutions, RegulatorySubmissions, StagingRegulatorySubmissions, and ValidationRule.
