-- ============================================================
-- MODULE 1 LAB
-- FILE 00: SQL SERVER DATA TYPES - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- SQL Server data types define what kind of values a column can store.
-- Python data types define what kind of values a Python variable can store.
-- Choosing the right SQL data type improves validation, storage, and query reliability.

-- Simple SQL Server to Python mapping:
-- VARCHAR, CHAR, NVARCHAR, NCHAR      -> str
-- INT, BIGINT, SMALLINT, TINYINT      -> int
-- DECIMAL, NUMERIC, MONEY             -> decimal.Decimal or float
-- FLOAT, REAL                         -> float
-- BIT                                 -> bool
-- DATE, TIME, DATETIME, DATETIME2     -> datetime.date, datetime.time, datetime.datetime
-- NULL                                -> None

-- 1. String data types.
-- VARCHAR stores variable-length non-Unicode text.
-- CHAR stores fixed-length non-Unicode text.
-- NVARCHAR stores variable-length Unicode text.
-- Example variables: CustomerName, CurrencyCode, CommentText.
DECLARE
    @CustomerName VARCHAR(100) = 'Maria',
    @CurrencyCode CHAR(3) = 'USD',
    @Comment NVARCHAR(200) = N'Customer record loaded';

SELECT
    @CustomerName AS CustomerName,
    @CurrencyCode AS CurrencyCode,
    @Comment AS CommentText;
GO

-- 2. Numeric data types.
-- INT stores whole numbers.
-- DECIMAL stores exact fixed-point numbers and is preferred for money-style values.
-- FLOAT stores approximate decimal values.
-- BIT stores 1, 0, or NULL and maps well to Python bool.
-- Example variables: CustomerID, AccountBalance, InterestRate, IsActive.
DECLARE
    @CustomerID INT = 1,
    @AccountBalance DECIMAL(18,2) = 12500.75,
    @InterestRate FLOAT = 4.25,
    @IsActive BIT = 1;

SELECT
    @CustomerID AS CustomerID,
    @AccountBalance AS AccountBalance,
    @InterestRate AS InterestRate,
    @IsActive AS IsActive;
GO

-- 3. Date and time data types.
-- DATE stores only a calendar date.
-- TIME stores only a time of day.
-- DATETIME2 stores date and time with better precision than DATETIME.
-- Example variables: OpenedDate, OpenedTime, CreatedAt.
DECLARE
    @OpenedDate DATE = '2026-06-21',
    @OpenedTime TIME = '09:30:00',
    @CreatedAt DATETIME2 = SYSDATETIME();

SELECT
    @OpenedDate AS OpenedDate,
    @OpenedTime AS OpenedTime,
    @CreatedAt AS CreatedAt;
GO

-- 4. Create a small demo table with common data types.
-- Table name: dbo.DataTypesDemo.
-- Fields:
-- DemoID INT IDENTITY PRIMARY KEY
-- CustomerName VARCHAR(100)
-- CurrencyCode CHAR(3)
-- AccountBalance DECIMAL(18,2)
-- InterestRate FLOAT
-- IsActive BIT
-- OpenedDate DATE
-- CreatedAt DATETIME2

-- 5. Insert sample rows.
-- Include string, numeric, bit, date, and NULL examples.

-- 6. Query the demo table.
-- Return all fields.
-- ORDER BY note: sort by DemoID.

-- 7. Inspect column metadata.
-- Use INFORMATION_SCHEMA.COLUMNS.
-- Return column name, data type, max length, precision, scale, and nullability.
-- ORDER BY note: sort by ORDINAL_POSITION.

-- Practice tasks:

-- Practice 1. Add another row to dbo.DataTypesDemo.
-- Use a new customer name, currency code, balance, interest rate, active flag, and opened date.

-- Practice 2. Select only active records.
-- Filter IsActive = 1.

-- Practice 3. Compare SQL and Python types.
-- Write comments showing which Python type matches CustomerName, AccountBalance, IsActive, and CreatedAt.
