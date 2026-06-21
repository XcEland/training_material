-- ============================================================
-- MODULE 1 LAB: SQL FUNDAMENTALS
-- FILE 03: DQL - SELECT QUERIES
-- ============================================================

-- DQL means Data Query Language.
-- SELECT is used to retrieve data from tables.

USE TrainingDB;
GO

-- 1. Retrieve all customers.
SELECT *
FROM dbo.Customers;
GO

-- 2. Select specific columns.
SELECT
    name,
    country
FROM dbo.Customers;
GO

-- 3. Use WHERE to filter records.
SELECT
    id,
    name,
    country,
    score
FROM dbo.Customers
WHERE score > 500;
GO

-- 4. Presentation-style query using LOWER().
-- Similar to:
-- SELECT name, LOWER(country)
-- FROM customers
-- WHERE country = 'Italy';
-- The local training rows use Germany, USA and UK.
SELECT
    name,
    LOWER(country) AS country_lowercase
FROM dbo.Customers
WHERE country = 'Germany';
GO

-- 5. Use ORDER BY.
SELECT
    id,
    name,
    country,
    score
FROM dbo.Customers
ORDER BY score DESC;
GO

-- 6. Use ORDER BY with more than one column.
SELECT
    id,
    name,
    country,
    score
FROM dbo.Customers
ORDER BY country ASC, score DESC;
GO

-- 7. Use GROUP BY to aggregate by country.
SELECT
    country,
    SUM(score) AS total_score
FROM dbo.Customers
GROUP BY country;
GO

-- 8. Use HAVING to filter after aggregation.
SELECT
    country,
    SUM(score) AS total_score
FROM dbo.Customers
GROUP BY country
HAVING SUM(score) > 800;
GO

-- 9. Use DISTINCT to remove duplicate country values.
SELECT DISTINCT
    country
FROM dbo.Customers;
GO

-- 10. Use TOP to restrict the number of rows returned.
SELECT TOP 3
    id,
    name,
    country,
    score
FROM dbo.Customers;
GO

-- 11. Query accounts with balances above a threshold.
SELECT
    AccountNumber,
    AccountType,
    Balance,
    CurrencyCode
FROM dbo.Accounts
WHERE Balance >= 10000
ORDER BY Balance DESC;
GO

-- 12. Join customers and accounts.
SELECT
    c.name,
    c.country,
    a.AccountNumber,
    a.AccountType,
    a.Balance,
    a.CurrencyCode
FROM dbo.Customers AS c
INNER JOIN dbo.Accounts AS a
    ON c.id = a.CustomerID;
GO

-- 13. Join customers, accounts and transactions.
SELECT
    c.name,
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionType,
    t.Amount,
    t.Channel
FROM dbo.Customers AS c
INNER JOIN dbo.Accounts AS a
    ON c.id = a.CustomerID
INNER JOIN dbo.Transactions AS t
    ON a.AccountID = t.AccountID
ORDER BY t.TransactionDate;
GO

-- 14. Aggregate transaction totals by transaction type.
SELECT
    TransactionType,
    COUNT(*) AS NumberOfTransactions,
    SUM(Amount) AS TotalAmount
FROM dbo.Transactions
GROUP BY TransactionType;
GO

-- 15. Aggregate balances by country.
SELECT
    c.country,
    COUNT(a.AccountID) AS NumberOfAccounts,
    SUM(a.Balance) AS TotalBalance
FROM dbo.Customers AS c
INNER JOIN dbo.Accounts AS a
    ON c.id = a.CustomerID
GROUP BY c.country
ORDER BY TotalBalance DESC;
GO
