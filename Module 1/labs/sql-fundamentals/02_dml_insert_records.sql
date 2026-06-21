-- ============================================================
-- MODULE 1 LAB: SQL FUNDAMENTALS
-- FILE 02: DML - INSERT RECORDS
-- ============================================================

-- DML means Data Manipulation Language.
-- INSERT is used to add records into existing tables.

USE TrainingDB;
GO

-- Insert customer records.
-- These rows match the SELECT training deck examples.
INSERT INTO dbo.Customers
    (id, name, country, score)
VALUES
    (1, 'Maria', 'Germany', 350),
    (2, 'John', 'USA', 900),
    (3, 'Georg', 'UK', 750),
    (4, 'Martin', 'Germany', 500),
    (5, 'Peter', 'USA', 0);
GO

-- Insert account records for the same customers.
INSERT INTO dbo.Accounts
    (CustomerID, AccountNumber, AccountType, Balance, CurrencyCode, OpenedDate, AccountStatus)
VALUES
    (1, 'DE100001', 'Savings', 15000.00, 'EUR', '2025-01-10', 'Active'),
    (2, 'US100002', 'Current', 27500.50, 'USD', '2025-02-15', 'Active'),
    (3, 'GB100003', 'Savings', 9800.00, 'GBP', '2025-03-20', 'Active'),
    (4, 'DE100004', 'Current', 1200.00, 'EUR', '2025-04-05', 'Active'),
    (5, 'US100005', 'Business', 250000.00, 'USD', '2025-05-12', 'Active');
GO

-- Insert transaction records.
INSERT INTO dbo.Transactions
    (AccountID, TransactionDate, TransactionType, Amount, Channel, Description)
VALUES
    (1, '2026-06-01 09:15:00', 'Deposit', 5000.00, 'Branch', 'Salary deposit'),
    (1, '2026-06-02 14:20:00', 'Withdrawal', 750.00, 'ATM', 'Cash withdrawal'),
    (2, '2026-06-03 10:00:00', 'Deposit', 10000.00, 'Mobile Banking', 'Transfer received'),
    (2, '2026-06-04 16:45:00', 'Withdrawal', 1200.00, 'POS', 'Retail payment'),
    (3, '2026-06-05 11:30:00', 'Deposit', 2500.00, 'Online Banking', 'Incoming EFT'),
    (4, '2026-06-06 12:10:00', 'Withdrawal', 100.00, 'ATM', 'Cash withdrawal'),
    (5, '2026-06-07 08:50:00', 'Deposit', 50000.00, 'Branch', 'Business deposit'),
    (5, '2026-06-08 13:35:00', 'Withdrawal', 15000.00, 'Online Banking', 'Supplier payment');
GO

-- Confirm inserted records.
SELECT 'Customers' AS TableName, COUNT(*) AS TotalRows FROM dbo.Customers
UNION ALL
SELECT 'Accounts' AS TableName, COUNT(*) AS TotalRows FROM dbo.Accounts
UNION ALL
SELECT 'Transactions' AS TableName, COUNT(*) AS TotalRows FROM dbo.Transactions;
GO
