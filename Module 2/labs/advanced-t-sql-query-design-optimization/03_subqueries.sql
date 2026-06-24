-- ============================================================
-- MODULE 2 LAB
-- FILE 03: SUBQUERIES
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A subquery is a query inside another query.
-- ORDER BY controls the display order of the final result set.
-- Use ORDER BY with TOP so the returned rows are predictable.
-- Examples progress from beginner single-value subqueries to EXISTS and correlated subqueries.

-- 1. Beginner scalar subquery: accounts for one named counterparty.
-- The inner query returns one CounterpartyID value.
SELECT
    a.AccountNumber,
    a.AccountType,
    a.CurrencyCode,
    a.CurrentBalance
FROM m2.Accounts AS a
WHERE a.CounterpartyID = (
    SELECT cp.CounterpartyID
    FROM m2.Counterparties AS cp
    WHERE cp.CounterpartyName = 'Maseru Commercial Bank'
)
ORDER BY a.AccountNumber;
GO

-- 2. Beginner scalar subquery: transactions above the overall average amount.
-- The inner query returns one average amount value.
SELECT TOP 20
    t.TransactionID,
    t.TransactionDate,
    t.CurrencyCode,
    t.Amount,
    t.Status,
    AVG(t.Amount) OVER() AS Average
FROM m2.FinancialTransactions AS t
WHERE t.Amount > (
    SELECT AVG(t2.Amount)
    FROM m2.FinancialTransactions AS t2
)
ORDER BY t.Amount DESC;
GO

-- 3. Scalar subquery: compare each transaction with the overall posted average.
-- The inner query returns one value.
SELECT TOP 20
    t.TransactionID,
    t.CurrencyCode,
    t.Amount,
    (
        SELECT AVG(t2.Amount)
        FROM m2.FinancialTransactions AS t2
        WHERE t2.Status = 'Posted'
    ) AS OverallPostedAverage
FROM m2.FinancialTransactions AS t
WHERE t.Status = 'Posted'
ORDER BY t.Amount DESC;
GO

-- 4. Correlated scalar subquery: compare with the average for the same currency.
-- The inner query depends on the outer row through t.CurrencyCode.
SELECT TOP 20
    t.TransactionID,
    t.CurrencyCode,
    t.Amount,
    (
        SELECT AVG(t2.Amount)
        FROM m2.FinancialTransactions AS t2
        WHERE t2.CurrencyCode = t.CurrencyCode
          AND t2.Status = 'Posted'
    ) AS AveragePostedAmountForCurrency
FROM m2.FinancialTransactions AS t
WHERE t.Status = 'Posted'
ORDER BY t.Amount DESC;
GO

-- 5. IN subquery: accounts linked to higher-risk counterparties.
-- The inner query returns a list of CounterpartyID values.
SELECT
    a.AccountNumber,
    a.AccountType,
    a.CurrencyCode,
    a.CurrentBalance
FROM m2.Accounts AS a
WHERE a.CounterpartyID IN (
    SELECT cp.CounterpartyID
    FROM m2.Counterparties AS cp
    WHERE cp.RiskRating IN ('Medium', 'High')
)
ORDER BY a.AccountNumber;
GO

-- 6. EXISTS subquery: counterparties with at least one posted transaction.
-- EXISTS checks whether the inner query finds any matching row.
SELECT
    cp.CounterpartyName,
    cp.Sector,
    cp.RiskRating
FROM m2.Counterparties AS cp
WHERE EXISTS (
    SELECT 1
    FROM m2.Accounts AS a
    INNER JOIN m2.FinancialTransactions AS t
        ON a.AccountID = t.AccountID
    WHERE a.CounterpartyID = cp.CounterpartyID
      AND t.Status = 'Posted'
)
ORDER BY cp.CounterpartyName;
GO

-- 7. Derived table subquery in the FROM clause.
-- First aggregate per account, then join the result to descriptive account data.
SELECT TOP 20
    a.AccountNumber,
    a.CurrencyCode,
    totals.TransactionCount,
    totals.TotalAmount
FROM (
    SELECT
        t.AccountID,
        COUNT(*) AS TransactionCount,
        SUM(t.Amount) AS TotalAmount
    FROM m2.FinancialTransactions AS t
    WHERE t.Status = 'Posted'
    GROUP BY t.AccountID
) AS totals
INNER JOIN m2.Accounts AS a
    ON totals.AccountID = a.AccountID
ORDER BY totals.TotalAmount DESC;
GO
