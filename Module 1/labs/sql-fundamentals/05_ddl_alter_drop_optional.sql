-- ============================================================
-- MODULE 1 LAB: SQL FUNDAMENTALS
-- FILE 05: OPTIONAL DDL - ALTER AND DROP
-- ============================================================

-- ALTER changes the structure of an existing database object.
-- DROP removes a database object.
-- Be careful with DROP because it can permanently remove objects.

USE TrainingDB;
GO

-- Add a new column to the Customers table if it does not already exist.
IF COL_LENGTH('dbo.Customers', 'PhoneNumber') IS NULL
BEGIN
    ALTER TABLE dbo.Customers
    ADD PhoneNumber VARCHAR(30) NULL;
END;
GO

-- Check that the new column exists.
SELECT
    id,
    name,
    PhoneNumber
FROM dbo.Customers;
GO

-- Update phone number for one customer.
UPDATE dbo.Customers
SET PhoneNumber = '+266 5000 0001'
WHERE name = 'Maria';
GO

-- Confirm phone number update.
SELECT
    name,
    PhoneNumber
FROM dbo.Customers
WHERE name = 'Maria';
GO

-- Optional DROP example.
-- Do not run this during the normal lab unless you want to remove the column.
-- ALTER TABLE dbo.Customers
-- DROP COLUMN PhoneNumber;
-- GO
