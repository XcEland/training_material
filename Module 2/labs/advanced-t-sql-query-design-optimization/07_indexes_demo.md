-- ============================================================
-- MODULE 2 LAB
-- FILE 07: INDEXES DEMO - LIVE CODING SCAFFOLD
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

-- Preview the main reporting table and current indexes.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;
SELECT TOP 20 * FROM sys.indexes AS i WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'm2';

-- Notes:
-- Indexes are physical structures that help SQL Server find rows faster.
-- Examples progress from existing indexes to single-column, composite, and covering indexes.
-- ORDER BY can benefit from an index when the index key order supports the requested sort.
-- For composite indexes, place equality columns before range columns when that matches the query pattern.
-- Avoid over-indexing; every extra index adds write and maintenance cost.
-- Run 06_large_scale_demo_data.sql before this file for a stronger large-table demonstration.
-- Keep STATISTICS IO/TIME on for measured SELECT queries and off while indexes are being created.

-- Reset lab-created indexes before baseline measurements.
-- Drop IX_M2_FinancialTransactions_TransactionDate if it exists.
-- Drop IX_M2_FinancialTransactions_DateCurrency if it exists.
-- Drop IX_M2_FinancialTransactions_CurrencyDate if it exists.
-- Drop IX_M2_FinancialTransactions_AccountDate if it exists.
-- Drop IX_M2_Accounts_Counterparty if it exists.
-- Drop stale statistics with those names only when they are not tied to an existing index.

-- Confirm the transaction row count.
-- Expected large-scale demo target: about 300,000 rows.

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- 1. Inspect current indexes on Module 2 tables.
-- Use sys.indexes and OBJECT_SCHEMA_NAME(i.object_id) = 'm2'.

-- 2. Baseline query before creating a supporting date index.
-- Filter transactions between '2026-06-01' and '2026-07-01'.
-- ORDER BY note: sort by TransactionDate DESC.

-- 3. Simple single-column index.
-- Index name: IX_M2_FinancialTransactions_TransactionDate.
-- Table: m2.FinancialTransactions.
-- Key column: TransactionDate.
-- Turn STATISTICS IO/TIME off before creating the index.
-- Drop the existing demo index first so this section can be rerun.
-- If a standalone statistic exists with the same name, drop it before CREATE INDEX.

-- 4. Re-run the same query and compare reads/plan shape.
-- Use the same date range as the baseline query.
-- Turn STATISTICS IO/TIME back on before measuring this query.

-- 5. Composite covering index for currency + date reporting.
-- Index name: IX_M2_FinancialTransactions_CurrencyDate.
-- Key columns: CurrencyCode, TransactionDate.
-- Equality predicate: CurrencyCode = 'USD'.
-- Range predicate: TransactionDate >= '2026-06-01' and TransactionDate < '2026-07-01'.
-- Included columns: Amount, Status, AccountID, TransactionType, ReferenceCode.
-- Turn STATISTICS IO/TIME off before creating the index.
-- Drop the existing demo index first so this section can be rerun.
-- If a standalone statistic exists with the same name, drop it before CREATE INDEX.

-- 6. Query that can benefit from the composite index.
-- Filter by TransactionDate range and CurrencyCode = 'USD'.
-- ORDER BY note: sort by Amount DESC to show high-value transactions first.
-- Turn STATISTICS IO/TIME back on before measuring this query.

-- 7. Join-supporting indexes.
-- FinancialTransactions index: AccountID, TransactionDate INCLUDE Amount, CurrencyCode, Status.
-- Accounts index: CounterpartyID INCLUDE AccountNumber, CurrencyCode, AccountType.
-- Turn STATISTICS IO/TIME off before creating the indexes.
-- Drop the existing demo indexes first so this section can be rerun.
-- If a standalone statistic exists with the same name, drop it before CREATE INDEX.

-- 8. Join query after supporting indexes.
-- Join FinancialTransactions to Accounts and Counterparties.
-- Turn STATISTICS IO/TIME back on before measuring this query.

-- 9. Inspect index usage after running the demos.
-- Use sys.indexes joined to sys.dm_db_index_usage_stats.
