-- ============================================================
-- MODULE 2 LAB
-- FILE 10: TRANSACTIONS AND ERROR HANDLING - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Table context
-- Schema: m2
-- m2.Counterparties fields: CounterpartyID, CounterpartyName, Sector, Country, RiskRating
-- m2.Accounts fields: AccountID, AccountNumber, CounterpartyID, AccountType, CurrencyCode, CurrentBalance, OpenedDate, AccountStatus
-- m2.FxRates fields: CurrencyCode, RateDate, RateToLSL
-- m2.FinancialTransactions fields: TransactionID, AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode, CreatedAt
-- m2.StagingTransactions fields: ReferenceCode, AccountNumber, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status
-- m2.MonthlyTransactionSummary fields: SummaryMonth, CurrencyCode, PostedTransactionCount, PostedAmount, LoadedAt
-- m2.TransactionAudit fields: AuditID, TransactionID, ActionName, OldStatus, NewStatus, OldAmount, NewAmount, ChangedBy, ChangedAt
-- m2.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorMessage
-- m2.OptimizationBenchmark fields: BenchmarkID, QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes, CapturedAt
-- System views used later: sys.indexes, sys.dm_db_index_usage_stats, sys.dm_exec_requests

-- Preview tables used for transaction/error handling examples.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t WHERE t.Status = 'Pending';
SELECT TOP 5 * FROM m2.TransactionAudit AS audit_log;
SELECT TOP 5 * FROM m2.ErrorLog AS error_log;

-- Notes:
-- A transaction groups changes so they succeed or fail together.
-- The examples cover rollback, commit, TRY/CATCH, and error logging.

SET XACT_ABORT ON;

-- 1. Simple transaction rollback.
-- The update happens inside the transaction, then ROLLBACK undoes it.
-- Select one pending TransactionID.
-- Show Status before rollback demo.
-- BEGIN TRANSACTION, update Status to 'Posted', show Status inside transaction, then ROLLBACK.
-- Show Status after rollback.

-- 2. Successful transaction with audit trail.
-- Select one pending transaction and capture old status/amount.
-- BEGIN TRY, BEGIN TRANSACTION.
-- Update Status to 'Posted'.
-- Insert a row into m2.TransactionAudit.
-- COMMIT TRANSACTION.
-- BEGIN CATCH: rollback if needed and insert into m2.ErrorLog.

-- 3. Failed transaction that rolls back and logs the error.
-- Intentionally insert a transaction with bad AccountID = 999999.
-- ReferenceCode: 'M2-BAD-ACCOUNT'.
-- Use TRY/CATCH and rollback.
-- Confirm RowsAfterRollback remains 0.
