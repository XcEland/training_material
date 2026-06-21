-- ============================================================
-- MODULE 2 LAB
-- FILE 06: EXECUTION PLANS DEMO - LIVE CODING SCAFFOLD
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

-- Preview the main reporting table.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;

-- Notes:
-- Execution plans show how SQL Server chooses to access, join, sort, and return data.
-- Statistics output helps compare logical reads and elapsed time.
-- ORDER BY can introduce sort work in the execution plan.
-- Compare Table Scan, Index Scan, Index Seek, Sort, Nested Loops, Hash Match, and Key Lookup operators.
-- Focus on logical reads first, then CPU time and elapsed time.
-- Run 06_large_scale_demo_data.sql before this file for a stronger large-table demonstration.

-- Statistics output to compare:
-- Table name: confirms which table SQL Server read.
-- Scan count: shows how many scan/seek operations were started.
-- Logical reads: pages read from memory; this is the main before/after comparison.
-- Physical reads: pages read from disk; this may be 0 when data is already cached.
-- CPU time: processor work used by the query.
-- Elapsed time: wall-clock duration of the query.

-- Reset lab-created indexes before baseline measurements.
-- Drop IX_M2_FinancialTransactions_TransactionDate if it exists.
-- Drop IX_M2_FinancialTransactions_DateCurrency if it exists.
-- Drop IX_M2_FinancialTransactions_CurrencyDate if it exists.
-- Drop IX_M2_FinancialTransactions_AccountDate if it exists.
-- Drop IX_M2_Accounts_Counterparty if it exists.

-- Confirm the transaction row count.
-- Expected large-scale demo target: about 300,000 rows.

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- 1. Simple selective query.
-- One table, a normal WHERE clause, and a small result set.
-- Filter: CurrencyCode = 'USD'.
-- ORDER BY note: sort by TransactionDate DESC.

-- 2. Non-sargable filter.
-- YEAR() and MONTH() are applied to the column, so SQL Server has less chance to seek efficiently.
-- Compare reads and plan shape with the next query.
-- Filter: YEAR(TransactionDate) = 2026 and MONTH(TransactionDate) = 6 and CurrencyCode = 'USD'.

-- 3. Sargable date range filter.
-- The date column is left unchanged; the range boundaries are on the constant side.
-- Filter: TransactionDate >= '2026-06-01' and TransactionDate < '2026-07-01'.

-- 4. SELECT * versus selected columns.
-- SELECT * can read and return more data than the report needs.
-- Compare SELECT * with selected output columns.
-- ORDER BY note: omitted here so the comparison focuses on selected columns versus SELECT *.

-- 5. Filter before joining large tables.
-- First narrow m2.FinancialTransactions to June 2026 posted rows.
-- Then join the filtered result to m2.Accounts and m2.Counterparties.
-- Compare plan shape and logical reads against the next join query.
-- ORDER BY note: sort by transaction date DESC.

-- 6. Join plan example.
-- Inspect join operators and which tables are scanned or sought.
-- Join FinancialTransactions to Accounts and Counterparties.
-- ORDER BY note: sort by t.TransactionDate DESC.

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
