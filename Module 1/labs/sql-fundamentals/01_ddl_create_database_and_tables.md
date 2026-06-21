-- ============================================================
-- MODULE 1 LAB
-- FILE 01: DDL - CREATE DATABASE AND TABLES - LIVE CODING SCAFFOLD
-- ============================================================

-- Database:
-- TrainingDB

-- Tables to create:
-- dbo.Customers
-- dbo.Accounts
-- dbo.Transactions

-- Table fields:
-- dbo.Customers fields: id, name, country, score
-- dbo.Accounts fields: AccountID, CustomerID, AccountNumber, AccountType, Balance, CurrencyCode, OpenedDate, AccountStatus
-- dbo.Transactions fields: TransactionID, AccountID, TransactionDate, TransactionType, Amount, Channel, Description

-- Relationships:
-- dbo.Accounts.CustomerID references dbo.Customers.id
-- dbo.Transactions.AccountID references dbo.Accounts.AccountID

-- Notes:
-- DDL means Data Definition Language.
-- DDL creates or changes database objects such as databases, tables, columns, constraints, and relationships.
-- Create parent tables before child tables.
-- Drop child tables before parent tables when resetting a lab.

-- 1. Create the database.
-- Check whether TrainingDB exists with DB_ID.
-- Create TrainingDB only when it does not already exist.

-- 2. Select the database.
-- Use TrainingDB before creating tables.

-- 3. Drop existing tables in dependency order.
-- Drop dbo.Transactions first because it depends on dbo.Accounts.
-- Drop dbo.Accounts next because it depends on dbo.Customers.
-- Drop dbo.Customers last.

-- 4. Create dbo.Customers.
-- id is the primary key.
-- name, country, and score are required fields.

-- 5. Create dbo.Accounts.
-- AccountID is an identity primary key.
-- CustomerID links the account to a customer.
-- AccountNumber should be unique.
-- Balance should use DECIMAL(18,2).
-- AccountStatus should default to Active.

-- 6. Create dbo.Transactions.
-- TransactionID is an identity primary key.
-- AccountID links each transaction to an account.
-- TransactionDate can default to GETDATE().
-- Description can allow NULL values.

-- 7. Confirm created tables.
-- Query INFORMATION_SCHEMA.TABLES.
-- ORDER BY note: sort by TABLE_NAME.

