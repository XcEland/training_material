-- ============================================================
-- MODULE 2 LAB
-- FILE 03: SUBQUERIES - LIVE CODING SCAFFOLD
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

-- Preview the tables used in the subqueries.
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;
SELECT TOP 5 * FROM m2.Accounts AS a;
SELECT TOP 5 * FROM m2.Counterparties AS cp;

-- Notes:
-- A subquery is a query inside another query.
-- ORDER BY controls the display order of the final result set.
-- Use ORDER BY to make demos easier to read, especially when using TOP.
-- Examples progress from beginner single-value subqueries to EXISTS and correlated subqueries.

-- 1. Beginner scalar subquery: accounts for one named counterparty.
-- The inner query returns one CounterpartyID value.
-- Outer table: m2.Accounts AS a.
-- Inner table: m2.Counterparties AS cp.
-- Filter: cp.CounterpartyName = 'Maseru Commercial Bank'.
-- Match: a.CounterpartyID = (inner query).
-- ORDER BY note: sort by a.AccountNumber for a stable account list.

-- 2. Beginner scalar subquery: transactions above the overall average amount.
-- The inner query returns one average amount value.
-- Outer table: m2.FinancialTransactions AS t.
-- Inner table: m2.FinancialTransactions AS t2.
-- Match: t.Amount > (SELECT AVG(t2.Amount) ...).
-- ORDER BY note: sort by t.Amount DESC to show the largest transactions first.

-- 3. Scalar subquery: compare each transaction with the overall posted average.
-- The inner query returns one value.
-- Inner query: AVG(t2.Amount) from m2.FinancialTransactions AS t2 where t2.Status = 'Posted'.
-- ORDER BY note: sort by t.Amount DESC to inspect high-value rows first.

-- 4. Correlated scalar subquery: compare with the average for the same currency.
-- The inner query depends on the outer row through t.CurrencyCode.
-- Inner query filters with t2.CurrencyCode = t.CurrencyCode and t2.Status = 'Posted'.
-- ORDER BY note: sort by t.Amount DESC to compare large transactions against the currency average.

-- 5. IN subquery: accounts linked to higher-risk counterparties.
-- The inner query returns a list of CounterpartyID values.
-- Use RiskRating IN ('Medium', 'High').
-- ORDER BY note: sort by a.AccountNumber for a predictable account list.

-- 6. EXISTS subquery: counterparties with at least one posted transaction.
-- EXISTS checks whether the inner query finds any matching row.
-- Use Counterparties AS cp outside and Accounts/FinancialTransactions inside.
-- ORDER BY note: sort by cp.CounterpartyName for readability.

-- 7. Derived table subquery in the FROM clause.
-- First aggregate per account, then join the result to descriptive account data.
-- Derived table fields: AccountID, TransactionCount, TotalAmount.
-- ORDER BY note: sort by totals.TotalAmount DESC to show the largest account totals first.

-- Practice tasks:

-- Practice 1. Beginner scalar subquery.
-- Find all accounts that belong to 'Cape Settlement Bank'.
-- Outer table: m2.Accounts AS a.
-- Inner table: m2.Counterparties AS cp.
-- Match a.CounterpartyID to the CounterpartyID returned by the inner query.
-- Return AccountNumber, AccountType, CurrencyCode, CurrentBalance.
-- ORDER BY note: sort by AccountNumber.

-- Practice 2. Beginner scalar subquery with an aggregate.
-- Find posted transactions where Amount is less than the overall posted average.
-- Outer table: m2.FinancialTransactions AS t.
-- Inner query: AVG(Amount) from posted transactions.
-- Return TransactionID, TransactionDate, Amount, CurrencyCode, Status.
-- ORDER BY note: sort by Amount ASC.

-- Practice 3. IN subquery.
-- Find accounts linked to counterparties in Lesotho.
-- Outer table: m2.Accounts AS a.
-- Inner table: m2.Counterparties AS cp.
-- Inner filter: cp.Country = 'Lesotho'.
-- Return AccountNumber, AccountType, CurrencyCode, CounterpartyID.
-- ORDER BY note: sort by AccountNumber.
