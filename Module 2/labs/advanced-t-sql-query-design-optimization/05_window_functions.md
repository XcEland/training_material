-- ============================================================
-- MODULE 2 LAB
-- FILE 05: WINDOW FUNCTIONS - LIVE CODING SCAFFOLD
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

-- Preview the tables used in the window function examples.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;
SELECT TOP 5 * FROM m2.Accounts AS a;
SELECT TOP 5 * FROM m2.Counterparties AS cp;

-- Notes:
-- Window functions calculate across related rows without collapsing the result like GROUP BY does.
-- Focus on OVER, PARTITION BY, and ORDER BY.

-- Simple comparison A: GROUP BY reduces rows.
-- Source table: m2.FinancialTransactions.
-- Filter: Status = 'Posted'.
-- Group by CurrencyCode.
-- Return one row per CurrencyCode with SUM(Amount).

-- Simple comparison B: PARTITION BY keeps all rows.
-- Source table: m2.FinancialTransactions.
-- Filter: Status = 'Posted'.
-- Use SUM(Amount) OVER (PARTITION BY CurrencyCode).
-- Return transaction rows with the currency total beside each row.

-- 1A. GROUP BY summary: one row per currency.
-- GROUP BY collapses each currency group into one summary row.
-- Source table: m2.FinancialTransactions.
-- Filter: Status = 'Posted'.
-- Group by CurrencyCode.
-- Aggregates: COUNT(*) AS PostedTransactionCount and SUM(Amount) AS PostedAmount.
-- ORDER BY note: sort by CurrencyCode.

-- 1B. Window aggregate summary: keep transaction rows and add group-level values.
-- The detail rows remain visible while the currency totals are repeated beside each row.
-- Source table: m2.FinancialTransactions.
-- Filter: Status = 'Posted'.
-- Use COUNT(*) OVER (PARTITION BY CurrencyCode).
-- Use SUM(Amount) OVER (PARTITION BY CurrencyCode).
-- Use AVG(Amount) OVER (PARTITION BY CurrencyCode).
-- Use MIN(Amount) OVER (PARTITION BY CurrencyCode).
-- Use MAX(Amount) OVER (PARTITION BY CurrencyCode).
-- ORDER BY note: sort by CurrencyCode, TransactionDate, TransactionID.

-- 2. ROW_NUMBER: number transactions inside each account.
-- Use ROW_NUMBER() OVER (PARTITION BY a.AccountNumber ORDER BY t.TransactionDate, t.TransactionID).

-- 3. RANK and DENSE_RANK: rank accounts by balance inside each currency.
-- Source table: m2.Accounts.
-- Use RANK() OVER (PARTITION BY CurrencyCode ORDER BY CurrentBalance DESC).
-- Use DENSE_RANK() OVER (PARTITION BY CurrencyCode ORDER BY CurrentBalance DESC).
-- RANK can leave gaps after ties. DENSE_RANK does not leave gaps after ties.
-- ORDER BY note: sort by CurrencyCode, BalanceRank, AccountNumber.

-- 4. NTILE: split accounts into balance bands inside each currency.
-- Source table: m2.Accounts.
-- Use NTILE(2) OVER (PARTITION BY CurrencyCode ORDER BY CurrentBalance DESC).
-- ORDER BY note: sort by CurrencyCode, BalanceBand, CurrentBalance DESC.

-- 5. RANK: rank counterparties by monthly transaction value.
-- First create MonthlyCounterpartyTotals.
-- Use RANK() OVER (PARTITION BY MonthStart ORDER BY TotalAmount DESC).

-- 6. Running total: cumulative transaction value by account.
-- Use SUM(t.Amount) OVER with PARTITION BY a.AccountNumber.
-- Order by t.TransactionDate, t.TransactionID.
-- Frame: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.

-- 7. LAG and LEAD: compare each daily total with the previous and next daily totals.
-- First create DailyTotals by CurrencyCode and TransactionDate.
-- Use LAG(DailyAmount) OVER (PARTITION BY CurrencyCode ORDER BY TransactionDate).
-- Use LEAD(DailyAmount) OVER (PARTITION BY CurrencyCode ORDER BY TransactionDate).

-- 8. FIRST_VALUE: compare each account to the largest account balance in its currency.
-- Source table: m2.Accounts.
-- Use FIRST_VALUE(AccountNumber) OVER (PARTITION BY CurrencyCode ORDER BY CurrentBalance DESC, AccountNumber).
-- Use FIRST_VALUE(CurrentBalance) OVER (PARTITION BY CurrencyCode ORDER BY CurrentBalance DESC, AccountNumber).
-- ORDER BY note: sort by CurrencyCode, CurrentBalance DESC.

-- 9. Window average: compare each transaction to the account average.
-- Use AVG(t.Amount) OVER (PARTITION BY a.AccountNumber).
-- Calculate DifferenceFromAccountAverage.

-- 10. PERCENT_RANK and CUME_DIST: show relative balance position by currency.
-- Source table: m2.Accounts.
-- Use PERCENT_RANK() OVER (PARTITION BY CurrencyCode ORDER BY CurrentBalance).
-- Use CUME_DIST() OVER (PARTITION BY CurrencyCode ORDER BY CurrentBalance).
-- Cast each relative ranking value as DECIMAL(6,4) for cleaner display.
-- ORDER BY note: sort by CurrencyCode, CurrentBalance.

-- Practice tasks:

-- Practice 1. Beginner ROW_NUMBER.
-- Number posted transactions by CurrencyCode.
-- Source table: m2.FinancialTransactions AS t.
-- Filter: t.Status = 'Posted'.
-- Use ROW_NUMBER() OVER (PARTITION BY t.CurrencyCode ORDER BY t.TransactionDate, t.TransactionID).
-- Return CurrencyCode, TransactionDate, TransactionID, Amount, and the row number.
-- ORDER BY note: sort by CurrencyCode, then the row number.

-- Practice 2. Beginner aggregate window function.
-- Show each posted transaction with the total posted amount for its currency.
-- Source table: m2.FinancialTransactions AS t.
-- Filter: t.Status = 'Posted'.
-- Use SUM(t.Amount) OVER (PARTITION BY t.CurrencyCode).
-- Return TransactionID, TransactionDate, CurrencyCode, Amount, and CurrencyPostedTotal.
-- ORDER BY note: sort by CurrencyCode, then Amount DESC.

-- Practice 3. Ranking.
-- Rank accounts by CurrentBalance inside each CurrencyCode.
-- Source table: m2.Accounts AS a.
-- Use RANK() OVER (PARTITION BY a.CurrencyCode ORDER BY a.CurrentBalance DESC).
-- Return AccountNumber, AccountType, CurrencyCode, CurrentBalance, and BalanceRank.
-- ORDER BY note: sort by CurrencyCode, then BalanceRank.

-- Practice 4. Value function.
-- Show each account beside the highest balance in its currency.
-- Source table: m2.Accounts AS a.
-- Use FIRST_VALUE(a.CurrentBalance) OVER (PARTITION BY a.CurrencyCode ORDER BY a.CurrentBalance DESC).
-- Return AccountNumber, CurrencyCode, CurrentBalance, and HighestBalanceForCurrency.
-- ORDER BY note: sort by CurrencyCode, then CurrentBalance DESC.
