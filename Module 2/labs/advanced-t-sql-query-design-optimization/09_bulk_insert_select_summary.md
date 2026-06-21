-- ============================================================
-- MODULE 2 LAB
-- FILE 09: BULK-STYLE INSERT SELECT SUMMARY LOAD - LIVE CODING SCAFFOLD
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

-- Preview the source table.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;

-- Notes:
-- INSERT ... SELECT is the core pattern behind many database load jobs.
-- The SELECT result defines the shape of the rows loaded into the summary table.

-- 1. Preview the monthly summary result before loading it.
-- Use DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS SummaryMonth.
-- Group by SummaryMonth and CurrencyCode.
-- Aggregate COUNT(*) AS PostedTransactionCount and SUM(Amount) AS PostedAmount.
-- Filter to Status = 'Posted'.

-- 2. Create the destination summary table.
-- Table: m2.MonthlyTransactionSummary.
-- Primary key: SummaryMonth, CurrencyCode.

-- 3. Clear old lab output so the load is repeatable.
-- Use TRUNCATE TABLE m2.MonthlyTransactionSummary.

-- 4. Bulk-style INSERT ... SELECT from a CTE.
-- CTE name: MonthlyTotals.
-- Insert SummaryMonth, CurrencyCode, PostedTransactionCount, PostedAmount.

-- 5. Verify loaded summary rows.
-- Select from m2.MonthlyTransactionSummary ordered by SummaryMonth, CurrencyCode.
