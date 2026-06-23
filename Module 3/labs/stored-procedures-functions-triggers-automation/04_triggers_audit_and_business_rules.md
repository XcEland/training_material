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
-- m3.trg_AfterInsertEmployee
-- m3.trg_StagingRegulatorySubmissions_InsertLog
-- m3.trg_StagingRegulatorySubmissions_DataValidation
-- m3.trg_RegulatorySubmissions_Audit
-- m3.trg_RegulatorySubmissions_BusinessRules
-- m3.trg_RegulatorySubmissions_PreventValidatedDelete

-- Preview tables used in this lab.
SELECT TOP 5 * FROM m3.RegulatorySubmissions;
SELECT TOP 5 * FROM m3.AuditLog;
SELECT TOP 5 * FROM m3.ErrorLog;

-- Notes:
-- A trigger runs automatically when a data change occurs on a table.
-- DML triggers respond to INSERT, UPDATE, and DELETE operations.
-- SQL Server does not use "CREATE" for row-level data changes; CREATE is a DDL operation.
-- DDL triggers for CREATE/ALTER/DROP objects are a separate advanced topic.
-- The inserted pseudo-table contains new row values.
-- The deleted pseudo-table contains old row values.
-- AFTER UPDATE and AFTER DELETE triggers can support audit trails.
-- AFTER INSERT and AFTER UPDATE triggers can enforce business rules.

-- Basic trigger structure:
-- CREATE TRIGGER TriggerName
-- ON TableName
-- AFTER INSERT, UPDATE, DELETE
-- AS
-- BEGIN
--     SQL statements go here.
-- END;

-- 1. Beginner employee insert log example.
-- Create m3.Employees.
-- Create m3.EmployeeLogs.
-- Create trigger m3.trg_AfterInsertEmployee ON m3.Employees AFTER INSERT.
-- Use inserted to read the new employee rows.
-- Insert one row into m3.EmployeeLogs for each inserted employee.
-- Insert Maria Doe into m3.Employees.
-- Query m3.EmployeeLogs to confirm the trigger fired.

-- 2. Basic staging insert logging trigger.
-- Trigger name: m3.trg_StagingRegulatorySubmissions_InsertLog.
-- Target table: m3.StagingRegulatorySubmissions.
-- Trigger timing: AFTER INSERT.
-- Insert one row into m3.AuditLog for each inserted staging row.

-- 3. Demonstrate the staging insert logging trigger.
-- Insert a temporary AUDITDEMO staging row.
-- Query m3.AuditLog for TableName = 'm3.StagingRegulatorySubmissions'.
-- Delete the temporary AUDITDEMO staging row after the log is created.

-- 4. Create data validation trigger m3.trg_StagingRegulatorySubmissions_DataValidation.
-- Target table: m3.StagingRegulatorySubmissions.
-- Trigger timing: AFTER INSERT, UPDATE.
-- Rule 1: InstitutionCode, ReportingPeriod, and ReportType are required.
-- Rule 2: TotalAssets and TotalLiabilities cannot be negative.
-- Rule 3: SubmissionStatus must be Received, Validated, Rejected, or Submitted.
-- Use THROW to reject invalid staging rows.
-- Demonstrate it with a row missing InstitutionCode.
-- Demonstrate it with an UPDATE that changes SubmissionStatus to Unknown.
-- Catch the error and log it to m3.ErrorLog.

-- 5. Create audit trigger m3.trg_RegulatorySubmissions_Audit.
-- Target table: m3.RegulatorySubmissions.
-- Trigger timing: AFTER UPDATE, DELETE.
-- Track SubmissionStatus changes.
-- Track TotalAssets changes.
-- Insert audit rows into m3.AuditLog.

-- 6. Create business-rule trigger m3.trg_RegulatorySubmissions_BusinessRules.
-- Target table: m3.RegulatorySubmissions.
-- Trigger timing: AFTER INSERT, UPDATE.
-- Rule 1: TotalAssets and TotalLiabilities cannot be negative.
-- Rule 2: TotalLiabilities cannot exceed TotalAssets.
-- Use THROW to reject invalid changes.

-- 7. Create delete-protection trigger m3.trg_RegulatorySubmissions_PreventValidatedDelete.
-- Target table: m3.RegulatorySubmissions.
-- Trigger timing: AFTER DELETE.
-- Rule: validated submissions cannot be deleted.
-- Use deleted to inspect the rows being deleted.

-- 8. Demonstrate audit trigger.
-- Update SubmissionStatus for SubmissionID = 4.
-- Query m3.AuditLog.
-- Insert a temporary non-validated row.
-- Delete that temporary row.
-- Query m3.AuditLog where OperationType = 'DELETE'.
-- ORDER BY note: sort newest first by AuditID DESC.

-- 9. Demonstrate INSERT/UPDATE business-rule trigger with handled error.
-- Try to insert a row with negative TotalAssets.
-- Use TRY/CATCH to catch the trigger error.
-- Insert error details into m3.ErrorLog.
-- Return a readable message.

-- 10. Demonstrate DELETE business-rule trigger with handled error.
-- Try to delete SubmissionID = 1.
-- The trigger blocks the delete because the row is Validated.
-- Insert error details into m3.ErrorLog.

-- 11. Review error log.
-- Query m3.ErrorLog.
-- ORDER BY note: sort newest first by ErrorLogID DESC.

-- Practice tasks:

-- Practice 1. Update TotalAssets for one valid submission.
-- Confirm that m3.AuditLog records the old and new value.

-- Practice 2. Try inserting a row where TotalLiabilities exceeds TotalAssets.
-- Confirm the trigger blocks the row.

-- Practice 3. Query audit activity by column name.
-- Filter m3.AuditLog where ColumnName = 'SubmissionStatus'.

-- Practice 4. Try inserting a staging row with SubmissionStatus = 'Unknown'.
-- Confirm the data validation trigger blocks it.
