-- ============================================================
-- MODULE 1 LAB
-- FILE 03: DQL - SELECT QUERIES - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- dbo.Customers fields: id, name, country, score
-- dbo.Accounts fields: AccountID, CustomerID, AccountNumber, AccountType, Balance, CurrencyCode, OpenedDate, AccountStatus
-- dbo.Transactions fields: TransactionID, AccountID, TransactionDate, TransactionType, Amount, Channel, Description

-- Useful join keys:
-- dbo.Customers.id = dbo.Accounts.CustomerID
-- dbo.Accounts.AccountID = dbo.Transactions.AccountID

-- Preview the tables used in SELECT examples.
SELECT TOP 5 * FROM dbo.Customers;
SELECT TOP 5 * FROM dbo.Accounts;
SELECT TOP 5 * FROM dbo.Transactions;

-- Notes:
-- DQL means Data Query Language.
-- SELECT retrieves records from tables.
-- WHERE filters rows before the final result is returned.
-- GROUP BY collapses rows into summary groups.
-- HAVING filters grouped results.
-- ORDER BY controls the display order of the final result set.

-- 1. Retrieve all customers.
-- Source table: dbo.Customers.
-- Use SELECT * for first inspection only.

-- 2. Select specific columns.
-- Source table: dbo.Customers.
-- Return name and country.

-- 3. Use WHERE to filter records.
-- Source table: dbo.Customers.
-- Filter: score > 500.

-- 4. Use a row-level function.
-- Source table: dbo.Customers.
-- Use LOWER(country) to display the country in lowercase.
-- Filter to country = 'Germany'.

-- 5. Use ORDER BY.
-- Source table: dbo.Customers.
-- Sort by score DESC.

-- 6. Use ORDER BY with more than one column.
-- Source table: dbo.Customers.
-- Sort by country ASC, then score DESC.

-- 7. Use GROUP BY to aggregate by country.
-- Source table: dbo.Customers.
-- Group by country.
-- Aggregate SUM(score) AS total_score.

-- 8. Use HAVING to filter after aggregation.
-- Group by country.
-- Keep countries where SUM(score) > 800.

-- 9. Use DISTINCT to remove duplicate country values.
-- Source table: dbo.Customers.
-- Return one row per country.

-- 10. Use TOP to restrict the number of rows returned.
-- Source table: dbo.Customers.
-- Return TOP 3 rows.

-- 11. Query accounts with balances above a threshold.
-- Source table: dbo.Accounts.
-- Filter: Balance >= 10000.
-- ORDER BY note: sort by Balance DESC.

-- 12. Join customers and accounts.
-- Join dbo.Customers AS c to dbo.Accounts AS a.
-- Match c.id = a.CustomerID.

-- 13. Join customers, accounts, and transactions.
-- Join Customers to Accounts, then Accounts to Transactions.
-- ORDER BY note: sort by t.TransactionDate.

-- 14. Aggregate transaction totals by transaction type.
-- Source table: dbo.Transactions.
-- Group by TransactionType.
-- Return COUNT(*) and SUM(Amount).

-- 15. Aggregate balances by country.
-- Join Customers to Accounts.
-- Group by c.country.
-- Return account count and total balance.
-- ORDER BY note: sort by TotalBalance DESC.

-- Practice tasks:

-- Practice 1. Retrieve customers from USA.
-- Return id, name, country, score.
-- ORDER BY note: sort by name.

-- Practice 2. Find accounts with USD currency.
-- Return AccountNumber, AccountType, Balance, CurrencyCode.
-- ORDER BY note: sort by Balance DESC.

-- Practice 3. Count transactions by channel.
-- Source table: dbo.Transactions.
-- Group by Channel.
-- Return Channel and COUNT(*) AS TransactionCount.

