-- ============================================================
-- MODULE 2 LAB
-- FILE 08: MERGE OPERATIONS - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Table context
-- Schema: m2
-- m2.Counterparties fields: CounterpartyID, CounterpartyName, Sector, Country, RiskRating
-- m2.Accounts fields: AccountID, AccountNumber, CounterpartyID, AccountType, CurrencyCode, CurrentBalance, OpenedDate, AccountStatus
-- m2.FxRates fields: CurrencyCode, RateDate, RateToLSL
-- m2.FinancialTransactions fields: TransactionID, AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode, CreatedAt
-- m2.StagingTransactions fields: ReferenceCode, AccountNumber, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status
-- m2.MonthlyTransactionSummary fields: SummaryMonth, CurrencyCode, PostedTransactionCount, PostedAmount, LoadedAt
-- m2.TransactionAudit fields: AuditID, TransactionID, ActionName, OldStatus, NewStatus, OldAmount, NewAmount, ChangedBy, ChangedAt
-- m2.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorMessage
-- m2.OptimizationBenchmark fields: BenchmarkID, QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes, CapturedAt
-- System views used later: sys.indexes, sys.dm_db_index_usage_stats, sys.dm_exec_requests

-- Preview source and target tables.
SELECT TOP 5 * FROM m2.StagingTransactions AS s;
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;
SELECT TOP 5 * FROM m2.Accounts AS a;

-- Notes:
-- MERGE compares a source dataset with a target table.
-- Source rows are previewed and classified before the MERGE operation runs.

-- Warm-up. Simple MERGE with temp tables.
-- Create #ProductTarget as the current data.
-- Create #ProductSource as the incoming data.
-- ProductID = 2 exists in both tables, so it should be updated.
-- ProductID = 3 exists only in the source table, so it should be inserted.
-- Use MERGE #ProductTarget AS target USING #ProductSource AS source.
-- Match on target.ProductID = source.ProductID.
-- WHEN MATCHED: update ProductName and Quantity.
-- WHEN NOT MATCHED: insert ProductID, ProductName, and Quantity.
-- Select #ProductTarget before and after MERGE to see the change.

-- 1. Review staging rows before loading.
-- Output: ReferenceCode, AccountNumber, TransactionDate, Amount, CurrencyCode, Status.

-- 2. Show which staging rows already exist in the target table.
-- LEFT JOIN StagingTransactions AS s to FinancialTransactions AS t.
-- Match on ReferenceCode.
-- Label rows as 'New row' or 'Existing row'.

-- 3. Clean and validate source rows before MERGE.
-- CTE name: CleanStage.
-- Join staging rows to Accounts by AccountNumber.
-- Keep rows where Amount > 0.

-- 4. MERGE staging data into the transaction table.
-- Target: m2.FinancialTransactions.
-- Source: CleanStage.
-- Match: target.ReferenceCode = source.ReferenceCode.
-- WHEN MATCHED: update transaction details.
-- WHEN NOT MATCHED: insert new transaction row.
-- OUTPUT MergeAction, inserted.ReferenceCode, inserted.TransactionID.
-- Use deleted.TransactionID IS NULL to label inserted rows; otherwise label the row as updated.

-- 5. Confirm the staging references now exist in the target table.
-- Query m2.FinancialTransactions for ReferenceCode values from m2.StagingTransactions.
