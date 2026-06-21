-- ============================================================
-- MODULE 1 LAB: SQL FUNDAMENTALS
-- FILE 00: SQL SERVER DATA TYPES
-- ============================================================

-- SQL Server data types define what kind of values a column can store.
-- Python data types define what kind of values a Python variable can store.

-- Simple SQL Server to Python mapping:
-- VARCHAR, CHAR, NVARCHAR, NCHAR      -> str
-- INT, BIGINT, SMALLINT, TINYINT      -> int
-- DECIMAL, NUMERIC, MONEY             -> decimal.Decimal or float
-- FLOAT, REAL                         -> float
-- BIT                                 -> bool
-- DATE, TIME, DATETIME, DATETIME2     -> datetime.date, datetime.time, datetime.datetime
-- NULL                                -> None

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

-- 1. String data types.
-- VARCHAR stores variable-length non-Unicode text.
-- CHAR stores fixed-length non-Unicode text.
-- NVARCHAR stores variable-length Unicode text.
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
-- DECIMAL stores exact fixed-point numbers, good for money-style values.
-- FLOAT stores approximate decimal values.
-- BIT stores 1, 0, or NULL and maps well to Python bool.
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
IF OBJECT_ID('dbo.DataTypesDemo', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DataTypesDemo;
END;
GO

CREATE TABLE dbo.DataTypesDemo (
    DemoID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    CurrencyCode CHAR(3) NOT NULL,
    AccountBalance DECIMAL(18,2) NOT NULL,
    InterestRate FLOAT NULL,
    IsActive BIT NOT NULL,
    OpenedDate DATE NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO dbo.DataTypesDemo
    (CustomerName, CurrencyCode, AccountBalance, InterestRate, IsActive, OpenedDate)
VALUES
    ('Maria', 'EUR', 15000.00, 4.25, 1, '2026-01-10'),
    ('John', 'USD', 27500.50, 3.75, 1, '2026-02-15'),
    ('Georg', 'GBP', 9800.00, NULL, 0, '2026-03-20');
GO

SELECT
    DemoID,
    CustomerName,
    CurrencyCode,
    AccountBalance,
    InterestRate,
    IsActive,
    OpenedDate,
    CreatedAt
FROM dbo.DataTypesDemo
ORDER BY DemoID;
GO

-- 5. Inspect the table columns and data types.
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'DataTypesDemo'
ORDER BY ORDINAL_POSITION;
GO
