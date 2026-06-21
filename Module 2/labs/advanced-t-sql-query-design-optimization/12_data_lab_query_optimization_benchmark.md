-- ============================================================
-- MODULE 2 DATA LAB
-- FILE 12: QUERY OPTIMIZATION BENCHMARK - LIVE CODING SCAFFOLD
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

-- Preview the tables used in the benchmark.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;
SELECT TOP 5 * FROM m2.Accounts AS a;
SELECT TOP 5 * FROM m2.Counterparties AS cp;
SELECT TOP 5 * FROM m2.OptimizationBenchmark AS b;

-- Data Lab goal:
-- 1. Run poor queries.
-- 2. Capture elapsed time and row counts.
-- 3. Apply an index or rewrite.
-- 4. Re-run and compare.
-- 5. Complete optimization_findings_template.md.

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Query 1 BEFORE: non-sargable date filter and SELECT *
-- Use YEAR(TransactionDate), MONTH(TransactionDate), CurrencyCode = 'USD', Status = 'Posted'.
-- Store rows in #Q1Before and insert benchmark result as QueryVersion = 'Before'.

-- Query 1 AFTER: sargable date range, selected columns, supporting index.
-- Create IX_M2_FinancialTransactions_DateCurrencyStatus.
-- Use TransactionDate >= '2026-06-01' and TransactionDate < '2026-07-01'.
-- Store rows in #Q1After and insert benchmark result as QueryVersion = 'After'.

-- Query 2 BEFORE: repeated correlated running-total subquery.
-- Join FinancialTransactions, Accounts, and Counterparties.
-- Use a correlated subquery to calculate RunningPostedAmount.
-- Store rows in #Q2Before and insert benchmark result.

-- Query 2 AFTER: window function computes running totals in one pass.
-- Use SUM(t.Amount) OVER (PARTITION BY t.AccountID ORDER BY t.TransactionDate, t.TransactionID).
-- Store rows in #Q2After and insert benchmark result.

-- Final output:
-- Select QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes, CapturedAt.

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
