-- ============================================================
-- MODULE 1 LAB
-- FILE 04: DML - UPDATE AND DELETE - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- dbo.Customers fields: id, name, country, score
-- dbo.Accounts fields: AccountID, CustomerID, AccountNumber, AccountType, Balance, CurrencyCode, OpenedDate, AccountStatus
-- dbo.Transactions fields: TransactionID, AccountID, TransactionDate, TransactionType, Amount, Channel, Description

-- Preview target records before changing them.
SELECT TOP 5 * FROM dbo.Customers;
SELECT TOP 5 * FROM dbo.Accounts;

-- Notes:
-- UPDATE changes existing records.
-- DELETE removes existing records.
-- Always use WHERE with UPDATE and DELETE unless the goal is to affect every row.
-- Check the row before and after changing it.

-- 1. Check customer before update.
-- Source table: dbo.Customers.
-- Filter: name = 'Martin'.

-- 2. Update one customer's score.
-- Target table: dbo.Customers.
-- Set score = 650.
-- Filter: name = 'Martin'.

-- 3. Confirm customer update.
-- Query dbo.Customers again for Martin.

-- 4. Update account status for a specific account.
-- Target table: dbo.Accounts.
-- Set AccountStatus = 'Dormant'.
-- Filter: AccountNumber = 'DE100004'.

-- 5. Confirm account update.
-- Return AccountNumber and AccountStatus.

-- 6. Insert a temporary test customer.
-- Target table: dbo.Customers.
-- Use this temporary row to demonstrate DELETE safely.

-- 7. View temporary customer.
-- Filter by name = 'Temporary Test Customer'.

-- 8. Delete only the temporary customer.
-- Target table: dbo.Customers.
-- Use WHERE name = 'Temporary Test Customer'.

-- 9. Confirm deletion.
-- Query the same temporary customer filter.

-- Practice tasks:

-- Practice 1. Update Peter's score.
-- First SELECT Peter's row.
-- Then UPDATE score to 100.
-- Confirm the change with another SELECT.

-- Practice 2. Mark account US100005 as Review.
-- First SELECT the account row.
-- Then UPDATE AccountStatus.
-- Confirm AccountNumber and AccountStatus.

