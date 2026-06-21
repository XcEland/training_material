-- ============================================================
-- MODULE 1 LAB: SQL FUNDAMENTALS
-- FILE 01: DDL - CREATE DATABASE AND TABLES
-- ============================================================

-- DDL means Data Definition Language.
-- It is used to define or change database objects such as databases,
-- tables, columns, constraints, and relationships.

-- Create the training database if it does not exist.
IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

-- Drop child table first because it depends on Accounts.
IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Transactions;
END;
GO

-- Drop Accounts before Customers because Accounts depends on Customers.
IF OBJECT_ID('dbo.Accounts', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Accounts;
END;
GO

IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Customers;
END;
GO

-- Create Customers table.
CREATE TABLE dbo.Customers (
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    score INT NOT NULL
);
GO

-- Create Accounts table.
CREATE TABLE dbo.Accounts (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountNumber VARCHAR(20) NOT NULL UNIQUE,
    AccountType VARCHAR(30) NOT NULL,
    Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    CurrencyCode CHAR(3) NOT NULL,
    OpenedDate DATE NOT NULL,
    AccountStatus VARCHAR(20) NOT NULL DEFAULT 'Active',

    CONSTRAINT FK_Accounts_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(id)
);
GO

-- Create Transactions table.
CREATE TABLE dbo.Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    TransactionType VARCHAR(20) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Channel VARCHAR(30) NOT NULL,
    Description VARCHAR(200) NULL,

    CONSTRAINT FK_Transactions_Accounts
        FOREIGN KEY (AccountID)
        REFERENCES dbo.Accounts(AccountID)
);
GO

-- Confirm created tables.
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
