-- ============================================================
-- MODULE 2 LAB
-- FILE 13: TABLE EXPRESSIONS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A table expression is a query that SQL Server can treat like a table.
-- Common table expressions include derived tables, CTEs, VALUES tables, and APPLY results.
-- Table expressions are useful when a query is easier to understand in small steps.

-- 1. Derived table: create a temporary result inside the FROM clause.
-- The inner query creates BalanceLabel, then the outer query filters on that label.
SELECT
    x.AccountNumber,
    x.CurrencyCode,
    x.CurrentBalance,
    x.BalanceLabel
FROM (
    SELECT
        AccountNumber,
        CurrencyCode,
        CurrentBalance,
        CASE
            WHEN CurrentBalance >= 1000000 THEN 'Large Balance'
            ELSE 'Normal Balance'
        END AS BalanceLabel
    FROM m2.Accounts
) AS x
WHERE x.BalanceLabel = 'Large Balance'
ORDER BY x.CurrentBalance DESC;
GO

-- 2. Derived table with aggregation.
-- The inner query totals posted transactions per currency.
-- The outer query displays only currencies above a chosen amount.
SELECT
    totals.CurrencyCode,
    totals.TransactionCount,
    totals.TotalAmount
FROM (
    SELECT
        CurrencyCode,
        COUNT(*) AS TransactionCount,
        SUM(Amount) AS TotalAmount
    FROM m2.FinancialTransactions
    WHERE Status = 'Posted'
    GROUP BY CurrencyCode
) AS totals
WHERE totals.TotalAmount > 50000
ORDER BY totals.TotalAmount DESC;
GO

-- 3. CTE table expression.
-- The CTE names the filtered rows, then the SELECT reads from that named result.
WITH ActiveAccounts AS (
    SELECT
        AccountNumber,
        AccountType,
        CurrencyCode,
        CurrentBalance
    FROM m2.Accounts
    WHERE AccountStatus = 'Active'
)
SELECT TOP 10
    AccountNumber,
    AccountType,
    CurrencyCode,
    CurrentBalance
FROM ActiveAccounts
ORDER BY AccountNumber;
GO

-- 4. VALUES table expression.
-- VALUES creates a tiny inline table of statuses we want to report on.
SELECT
    s.StatusName,
    COUNT(t.TransactionID) AS TransactionCount
FROM (
    VALUES
        ('Posted'),
        ('Pending'),
        ('Failed')
) AS s(StatusName)
LEFT JOIN m2.FinancialTransactions AS t
    ON t.Status = s.StatusName
GROUP BY s.StatusName
ORDER BY s.StatusName;
GO

-- 5. APPLY table expression.
-- OUTER APPLY returns the latest transaction for each account.
-- If an account has no transactions, the account still appears with NULL transaction fields.
SELECT TOP 10
    a.AccountNumber,
    a.CurrencyCode,
    latest.TransactionDate,
    latest.Amount,
    latest.Status
FROM m2.Accounts AS a
OUTER APPLY (
    SELECT TOP 1
        t.TransactionDate,
        t.Amount,
        t.Status
    FROM m2.FinancialTransactions AS t
    WHERE t.AccountID = a.AccountID
    ORDER BY t.TransactionDate DESC, t.TransactionID DESC
) AS latest
ORDER BY a.AccountNumber;
GO
