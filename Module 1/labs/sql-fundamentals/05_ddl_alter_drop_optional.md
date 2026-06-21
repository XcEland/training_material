-- ============================================================
-- MODULE 1 LAB
-- FILE 05: OPTIONAL DDL - ALTER AND DROP - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields before ALTER:
-- dbo.Customers fields: id, name, country, score

-- Notes:
-- ALTER changes the structure of an existing database object.
-- DROP removes a database object.
-- DROP can permanently remove objects or columns, so use it carefully.

-- 1. Add a new column to dbo.Customers.
-- Column name: PhoneNumber.
-- Data type: VARCHAR(30).
-- Allow NULL values.
-- Use COL_LENGTH to check whether the column already exists.

-- 2. Check that the new column exists.
-- Query id, name, and PhoneNumber from dbo.Customers.

-- 3. Update phone number for one customer.
-- Target table: dbo.Customers.
-- Set PhoneNumber for Maria.

-- 4. Confirm phone number update.
-- Return name and PhoneNumber for Maria.

-- 5. Optional DROP example.
-- DROP COLUMN removes the column from the table.
-- Do not run the DROP example during the normal lab unless the goal is to remove the column.

