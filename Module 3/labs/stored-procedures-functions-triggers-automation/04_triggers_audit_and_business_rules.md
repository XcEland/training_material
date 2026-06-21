-- ============================================================
-- MODULE 3 LAB
-- FILE 04: TRIGGERS FOR AUDIT AND BUSINESS RULES - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- m3.RegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.AuditLog fields: AuditID, TableName, OperationType, PrimaryKeyValue, ColumnName, OldValue, NewValue, ChangedBy, ChangedAt
-- m3.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage

-- Trigger names:
-- m3.trg_StagingRegulatorySubmissions_InsertLog
-- m3.trg_RegulatorySubmissions_Audit
-- m3.trg_RegulatorySubmissions_BusinessRules

-- Preview tables used in this lab.
SELECT TOP 5 * FROM m3.RegulatorySubmissions;
SELECT TOP 5 * FROM m3.AuditLog;
SELECT TOP 5 * FROM m3.ErrorLog;

-- Notes:
-- A trigger runs automatically when a data change occurs on a table.
-- The inserted pseudo-table contains new row values.
-- The deleted pseudo-table contains old row values.
-- AFTER UPDATE and AFTER DELETE triggers can support audit trails.
-- AFTER INSERT and AFTER UPDATE triggers can enforce business rules.

-- 1. Basic insert logging trigger.
-- Trigger name: m3.trg_StagingRegulatorySubmissions_InsertLog.
-- Target table: m3.StagingRegulatorySubmissions.
-- Trigger timing: AFTER INSERT.
-- Insert one row into m3.AuditLog for each inserted staging row.

-- 2. Demonstrate the basic insert logging trigger.
-- Insert a temporary AUDITDEMO staging row.
-- Query m3.AuditLog for TableName = 'm3.StagingRegulatorySubmissions'.
-- Delete the temporary AUDITDEMO staging row after the log is created.

-- 3. Create audit trigger m3.trg_RegulatorySubmissions_Audit.
-- Target table: m3.RegulatorySubmissions.
-- Trigger timing: AFTER UPDATE, DELETE.
-- Track SubmissionStatus changes.
-- Track TotalAssets changes.
-- Insert audit rows into m3.AuditLog.

-- 4. Create business-rule trigger m3.trg_RegulatorySubmissions_BusinessRules.
-- Target table: m3.RegulatorySubmissions.
-- Trigger timing: AFTER INSERT, UPDATE.
-- Rule 1: TotalAssets and TotalLiabilities cannot be negative.
-- Rule 2: TotalLiabilities cannot exceed TotalAssets.
-- Use THROW to reject invalid changes.

-- 5. Demonstrate audit trigger.
-- Update SubmissionStatus for SubmissionID = 4.
-- Query m3.AuditLog.
-- ORDER BY note: sort newest first by AuditID DESC.

-- 6. Demonstrate business-rule trigger with handled error.
-- Try to insert a row with negative TotalAssets.
-- Use TRY/CATCH to catch the trigger error.
-- Insert error details into m3.ErrorLog.
-- Return a readable message.

-- 7. Review error log.
-- Query m3.ErrorLog.
-- ORDER BY note: sort newest first by ErrorLogID DESC.

-- Practice tasks:

-- Practice 1. Update TotalAssets for one valid submission.
-- Confirm that m3.AuditLog records the old and new value.

-- Practice 2. Try inserting a row where TotalLiabilities exceeds TotalAssets.
-- Confirm the trigger blocks the row.

-- Practice 3. Query audit activity by column name.
-- Filter m3.AuditLog where ColumnName = 'SubmissionStatus'.
