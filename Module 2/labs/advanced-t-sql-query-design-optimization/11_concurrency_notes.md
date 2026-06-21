-- ============================================================
-- MODULE 2 LAB
-- FILE 11: CONCURRENCY NOTES - LIVE CODING SCAFFOLD
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

-- Preview the account used for the locking example.
SELECT * FROM m2.Accounts AS a WHERE a.AccountNumber = 'M2-LSL-0001';

-- Notes:
-- Concurrency is about what happens when two users or jobs touch the same data at the same time.
-- Locking hints can protect critical business checks when concurrent activity is possible.

-- 1. Read the account normally.
-- Select AccountID, AccountNumber, CurrentBalance from m2.Accounts.
-- Filter AccountNumber = 'M2-LSL-0001'.

-- 2. Locking pattern for a protected business check.
-- BEGIN TRANSACTION.
-- Select the same account WITH (UPDLOCK, HOLDLOCK).
-- ROLLBACK TRANSACTION.

-- 3. Active-request query: show active sessions and requests.
-- Query sys.dm_exec_requests.
-- Filter database_id = DB_ID().
