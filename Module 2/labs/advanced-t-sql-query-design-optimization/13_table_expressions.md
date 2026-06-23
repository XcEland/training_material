-- ============================================================
-- MODULE 2 LAB
-- FILE 13: TABLE EXPRESSIONS - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Table context
-- Schema: m2
-- m2.Counterparties fields: CounterpartyID, CounterpartyName, Sector, Country, RiskRating
-- m2.Accounts fields: AccountID, AccountNumber, CounterpartyID, AccountType, CurrencyCode, CurrentBalance, OpenedDate, AccountStatus
-- m2.FinancialTransactions fields: TransactionID, AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode, CreatedAt

-- Notes:
-- A table expression is a query SQL Server can treat like a table.
-- Useful forms: derived table, CTE, VALUES table, APPLY.
-- Keep the inner query small, then read from it in the outer query.

-- 1. Derived table.
-- Build a result set inside FROM.
-- Add a BalanceLabel column with CASE.
-- Outer query filters BalanceLabel = 'Large Balance'.

-- 2. Derived table with aggregation.
-- Inner query groups posted transactions by CurrencyCode.
-- Outer query filters TotalAmount > 50000.

-- 3. CTE table expression.
-- WITH ActiveAccounts AS (...).
-- Final SELECT reads from ActiveAccounts.

-- 4. VALUES table expression.
-- Create an inline table with Posted, Pending, Failed.
-- LEFT JOIN it to m2.FinancialTransactions.
-- Count transactions per status.

-- 5. APPLY table expression.
-- Read from m2.Accounts.
-- OUTER APPLY a TOP 1 transaction query per account.
-- This returns the latest transaction for each account.
