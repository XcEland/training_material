-- ============================================================
-- MODULE 2 DATA LAB
-- FILE 12: QUERY OPTIMIZATION BENCHMARK - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Table context
-- Schema: m2
-- Main table: m2.FinancialTransactions
-- Supporting tables: m2.Accounts, m2.Counterparties

-- Data Lab goal:
-- 1. Run each BEFORE query.
-- 2. Check Messages for logical reads and CPU time.
-- 3. Check the XML execution plan output.
-- 4. Run the matching AFTER query.
-- 5. Compare reads, time, row counts, and plan shape.

-- Turn these on before each query section:
-- SET STATISTICS IO ON;
-- SET STATISTICS TIME ON;
-- SET STATISTICS XML ON;

-- Turn these off after each query section:
-- SET STATISTICS XML OFF;
-- SET STATISTICS TIME OFF;
-- SET STATISTICS IO OFF;

-- ------------------------------------------------------------
-- Query 1 BEFORE: non-sargable date filter and SELECT *
-- ------------------------------------------------------------
-- Use YEAR(TransactionDate) = 2026.
-- Use MONTH(TransactionDate) = 6.
-- Filter CurrencyCode = 'USD' and Status = 'Posted'.
-- Store rows in #Q1Before.

-- ------------------------------------------------------------
-- Query 2 BEFORE: repeated correlated running-total subquery
-- ------------------------------------------------------------
-- Join FinancialTransactions, Accounts, and Counterparties.
-- Use a correlated subquery to calculate RunningPostedAmount.
-- Store TOP 500 rows in #Q2Before.

-- ------------------------------------------------------------
-- Query 3 BEFORE: filter after grouping
-- ------------------------------------------------------------
-- Group by CurrencyCode and Status.
-- Use HAVING Status = 'Posted'.
-- Store rows in #Q3Before.

-- ------------------------------------------------------------
-- Query 4 BEFORE: function on filtered column
-- ------------------------------------------------------------
-- Use UPPER(Status) = 'POSTED'.
-- Store TOP 500 rows in #Q4Before.

-- ------------------------------------------------------------
-- Improvement 1: rewrite inefficient queries
-- ------------------------------------------------------------
-- Query 1: replace YEAR/MONTH with a date range.
-- Query 2: replace the correlated subquery with a window function.
-- Query 3: move Status filtering before GROUP BY.
-- Query 4: remove UPPER() from the filtered column.

-- ------------------------------------------------------------
-- Improvement 2: add a proper index
-- ------------------------------------------------------------
-- Create IX_M2_FinancialTransactions_StatusDate.
-- Key columns: Status, TransactionDate.
-- Use it for common Status and date filters.

-- ------------------------------------------------------------
-- Improvement 3: use a covering index
-- ------------------------------------------------------------
-- Create IX_M2_FinancialTransactions_Q1Covering.
-- Key columns: TransactionDate, CurrencyCode, Status.
-- Included columns: TransactionID, AccountID, TransactionType, Amount, ReferenceCode.
-- Use it to support Query 1 AFTER without needing extra lookups for selected columns.

-- ------------------------------------------------------------
-- Query 1 AFTER: sargable date range and selected columns
-- ------------------------------------------------------------
-- Select only the needed columns.
-- Use TransactionDate >= '2026-06-01'.
-- Use TransactionDate < '2026-07-01'.
-- Keep CurrencyCode = 'USD' and Status = 'Posted'.
-- Store rows in #Q1After.

-- ------------------------------------------------------------
-- Query 2 AFTER: window function running total
-- ------------------------------------------------------------
-- Use SUM(t.Amount) OVER (
--     PARTITION BY t.AccountID
--     ORDER BY t.TransactionDate, t.TransactionID
-- ).
-- Store TOP 500 rows in #Q2After.

-- ------------------------------------------------------------
-- Query 3 AFTER: filter before grouping
-- ------------------------------------------------------------
-- Use WHERE Status = 'Posted' before GROUP BY.
-- Group only by CurrencyCode.
-- Store rows in #Q3After.

-- ------------------------------------------------------------
-- Query 4 AFTER: direct predicate on filtered column
-- ------------------------------------------------------------
-- Use Status = 'Posted'.
-- Store TOP 500 rows in #Q4After.

-- Final check:
-- Return row counts from #Q1Before, #Q1After, #Q2Before, #Q2After,
-- #Q3Before, #Q3After, #Q4Before, and #Q4After.

-- Record findings:
-- - Logical reads
-- - CPU time
-- - Elapsed time
-- - Operators seen in the XML plan
-- - What changed between BEFORE and AFTER
