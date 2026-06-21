-- ============================================================
-- MODULE 1 LAB
-- FILE 02: DML - INSERT RECORDS - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- dbo.Customers fields: id, name, country, score
-- dbo.Accounts fields: AccountID, CustomerID, AccountNumber, AccountType, Balance, CurrencyCode, OpenedDate, AccountStatus
-- dbo.Transactions fields: TransactionID, AccountID, TransactionDate, TransactionType, Amount, Channel, Description

-- Relationships:
-- dbo.Accounts.CustomerID references dbo.Customers.id
-- dbo.Transactions.AccountID references dbo.Accounts.AccountID

-- Preview table structure before inserting.
SELECT TOP 5 * FROM dbo.Customers;
SELECT TOP 5 * FROM dbo.Accounts;
SELECT TOP 5 * FROM dbo.Transactions;

-- Notes:
-- DML means Data Manipulation Language.
-- INSERT adds records into existing tables.
-- Insert parent table rows before child table rows.

-- 1. Insert customer records.
-- Target table: dbo.Customers.
-- Columns: id, name, country, score.
-- Customer sample values: Maria, John, Georg, Martin, Peter.
-- Countries used: Germany, USA, UK.

-- 2. Insert account records.
-- Target table: dbo.Accounts.
-- Columns: CustomerID, AccountNumber, AccountType, Balance, CurrencyCode, OpenedDate, AccountStatus.
-- CustomerID values must already exist in dbo.Customers.

-- 3. Insert transaction records.
-- Target table: dbo.Transactions.
-- Columns: AccountID, TransactionDate, TransactionType, Amount, Channel, Description.
-- AccountID values must already exist in dbo.Accounts.

-- 4. Confirm inserted records.
-- Count rows in dbo.Customers, dbo.Accounts, and dbo.Transactions.
-- Use UNION ALL to return the counts in one result set.

