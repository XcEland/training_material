-- ============================================================
-- MODULE 1 LAB: SQL FUNDAMENTALS
-- FILE 04: DML - UPDATE AND DELETE
-- ============================================================

-- UPDATE changes existing records.
-- DELETE removes existing records.
-- Always use WHERE with UPDATE and DELETE unless you intentionally
-- want to affect every row.

USE TrainingDB;
GO

-- Check customer before update.
SELECT *
FROM dbo.Customers
WHERE name = 'Martin';
GO

-- Update one customer's score.
UPDATE dbo.Customers
SET score = 650
WHERE name = 'Martin';
GO

-- Confirm update.
SELECT *
FROM dbo.Customers
WHERE name = 'Martin';
GO

-- Update account status for a specific account.
UPDATE dbo.Accounts
SET AccountStatus = 'Dormant'
WHERE AccountNumber = 'DE100004';
GO

-- Confirm account update.
SELECT
    AccountNumber,
    AccountStatus
FROM dbo.Accounts
WHERE AccountNumber = 'DE100004';
GO

-- Insert a temporary test customer to demonstrate DELETE safely.
INSERT INTO dbo.Customers
    (id, name, country, score)
VALUES
    (99, 'Temporary Test Customer', 'Lesotho', 100);
GO

-- View temporary customer.
SELECT *
FROM dbo.Customers
WHERE name = 'Temporary Test Customer';
GO

-- Delete only the temporary customer.
DELETE FROM dbo.Customers
WHERE name = 'Temporary Test Customer';
GO

-- Confirm deletion.
SELECT *
FROM dbo.Customers
WHERE name = 'Temporary Test Customer';
GO
