-- ============================================================
-- MODULE 2 LAB
-- FILE 06: LARGE-SCALE DEMO DATA - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Table context
-- Schema: m2
-- m2.Accounts fields: AccountID, AccountNumber, CounterpartyID, AccountType, CurrencyCode, CurrentBalance, OpenedDate, AccountStatus
-- m2.FinancialTransactions fields: TransactionID, AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode, CreatedAt

-- Preview the current transaction volume.
SELECT COUNT(*) AS CurrentTransactionRows FROM m2.FinancialTransactions;

-- Notes:
-- This script increases the transaction table to about 300,000 rows.
-- The larger table makes execution plans, logical reads, and index effects easier to compare.
-- Use set-based INSERT ... SELECT instead of row-by-row inserts.
-- The generated ReferenceCode values start with M2X- so the extra demo rows are easy to identify.

-- 1. Set the target row count.
-- Target rows: 300000.
-- Current rows: COUNT(*) from m2.FinancialTransactions.
-- Rows to add: target rows minus current rows.

-- 2. Generate row numbers using sys.all_objects cross joins.
-- Use ROW_NUMBER() to produce a stable sequence for generated rows.

-- 3. Prepare generated transaction values.
-- AccountID cycles through the 15 demo accounts.
-- TransactionDate cycles across January to June 2026.
-- Amount, TransactionType, Channel, and Status are generated from the row number.

-- 4. Insert generated rows into m2.FinancialTransactions.
-- Join to m2.Accounts to reuse the account currency.
-- Use NOT EXISTS on ReferenceCode so the script can be re-run safely.

-- 5. Confirm the final row count.
-- Return total rows, earliest transaction date, and latest transaction date.
