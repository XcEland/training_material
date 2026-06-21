-- ============================================================
-- MODULE 2 LAB
-- FILE 04: COMMON TABLE EXPRESSIONS - LIVE CODING SCAFFOLD
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

-- Preview the tables used in the CTE examples.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;
SELECT TOP 5 * FROM m2.Accounts AS a;
SELECT TOP 5 * FROM m2.Counterparties AS cp;
SELECT TOP 5 * FROM m2.FxRates AS fx;

-- Notes:
-- A CTE helps you name a temporary result set for the next SELECT.
-- Use CTEs to make multi-step reporting logic easier to read.
-- CTEs work well with aggregate functions when a report needs several logical steps.
-- ORDER BY controls the display order of the final SELECT after the CTE has been built.

-- 1. Simple CTE: name the filtered transaction set.
-- CTE name: PostedTransactions.
-- Filter: Status = 'Posted'.
-- Return TransactionID, TransactionDate, Amount, CurrencyCode.
-- ORDER BY note: sort by TransactionDate DESC, then TransactionID DESC.

-- 2. CTE with aggregate functions: posted transaction profile by currency.
-- CTE name: CurrencyTransactionProfile.
-- Source table: m2.FinancialTransactions.
-- Filter: Status = 'Posted'.
-- Group by CurrencyCode.
-- Aggregate functions: COUNT(*) AS TransactionCount, SUM(Amount) AS TotalAmount,
-- AVG(Amount) AS AverageAmount, MIN(Amount) AS SmallestAmount, MAX(Amount) AS LargestAmount.
-- ORDER BY note: sort by CurrencyCode.

-- 3. CTE with date grouping: monthly totals by currency.
-- CTE name: MonthlyCurrencyTotals.
-- Use DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS MonthStart.
-- Aggregate COUNT(*) AS TransactionCount and SUM(Amount) AS TotalAmount.
-- ORDER BY note: sort by MonthStart DESC, then CurrencyCode.

-- 4. CTE followed by a join.
-- CTE name: AccountTotals.
-- Aggregate posted transactions by AccountID.
-- Join the CTE to Accounts and Counterparties.
-- ORDER BY note: sort by TotalAmount DESC to show the largest account totals first.

-- 5. Multiple CTEs: build a readable reporting pipeline.
-- CTE 1: PostedTransactions.
-- CTE 2: ConvertedTransactions with AmountLSL.
-- CTE 3: MonthlyCounterpartyTotals.
-- Final output: CounterpartyName, MonthStart, TransactionCount, TotalAmountLSL.
-- ORDER BY note: sort by MonthStart DESC, then TotalAmountLSL DESC.

-- 6. Recursive CTE: generate a month calendar for reporting.
-- The first SELECT is the anchor row.
-- The second SELECT uses UNION ALL to add the next month.
-- CTE name: MonthCalendar.
-- Anchor row: CAST('2026-01-01' AS DATE) AS MonthStart.
-- Recursive row: DATEADD(MONTH, 1, MonthStart).
-- Stop condition: MonthStart < '2026-06-01'.
-- Second CTE name: MonthlyPostedTotals.
-- Join MonthCalendar to MonthlyPostedTotals with LEFT JOIN.
-- Use COALESCE to display 0 when a month has no matching totals.
-- ORDER BY note: sort by MonthCalendar.MonthStart.
-- MAXRECURSION note: OPTION (MAXRECURSION 12) allows enough recursive steps for this six-month calendar.

-- Practice tasks:

-- Practice 1. Beginner CTE.
-- Create a CTE named ActiveAccounts.
-- Source table: m2.Accounts.
-- Filter: AccountStatus = 'Active'.
-- Return AccountNumber, AccountType, CurrencyCode, CurrentBalance.
-- ORDER BY note: sort by AccountNumber.

-- Practice 2. CTE with aggregation.
-- Create a CTE named StatusTotals.
-- Source table: m2.FinancialTransactions.
-- Group by Status.
-- Aggregate COUNT(*) AS TransactionCount and SUM(Amount) AS TotalAmount.
-- Return Status, TransactionCount, TotalAmount.
-- ORDER BY note: sort by TransactionCount DESC.

-- Practice 3. CTE followed by a join.
-- Create a CTE named CounterpartyAccountCounts.
-- Source table: m2.Accounts.
-- Group by CounterpartyID.
-- Aggregate COUNT(*) AS AccountCount.
-- Join the CTE to m2.Counterparties.
-- Return CounterpartyName, Sector, Country, AccountCount.
-- ORDER BY note: sort by AccountCount DESC, then CounterpartyName.
