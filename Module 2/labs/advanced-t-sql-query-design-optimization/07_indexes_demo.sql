-- ============================================================
-- MODULE 2 LAB
-- FILE 07: INDEXES DEMO
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- Indexes are physical structures that help SQL Server find rows faster.
-- Examples progress from existing indexes to single-column, composite, and covering indexes.
-- For composite indexes, place equality columns before range columns when that matches the query pattern.
-- Avoid over-indexing; every extra index adds write and maintenance cost.

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_TransactionDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_TransactionDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_FinancialTransactions_TransactionDate'
      AND s.object_id = OBJECT_ID('m2.FinancialTransactions')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.FinancialTransactions.IX_M2_FinancialTransactions_TransactionDate;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_DateCurrency'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_DateCurrency ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_FinancialTransactions_DateCurrency'
      AND s.object_id = OBJECT_ID('m2.FinancialTransactions')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.FinancialTransactions.IX_M2_FinancialTransactions_DateCurrency;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_CurrencyDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_CurrencyDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_FinancialTransactions_CurrencyDate'
      AND s.object_id = OBJECT_ID('m2.FinancialTransactions')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.FinancialTransactions.IX_M2_FinancialTransactions_CurrencyDate;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_AccountDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_AccountDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_FinancialTransactions_AccountDate'
      AND s.object_id = OBJECT_ID('m2.FinancialTransactions')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.FinancialTransactions.IX_M2_FinancialTransactions_AccountDate;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_Accounts_Counterparty'
      AND object_id = OBJECT_ID('m2.Accounts')
)
BEGIN
    DROP INDEX IX_M2_Accounts_Counterparty ON m2.Accounts;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_Accounts_Counterparty'
      AND s.object_id = OBJECT_ID('m2.Accounts')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.Accounts.IX_M2_Accounts_Counterparty;
END;
GO

SELECT
    COUNT(*) AS FinancialTransactionRows
FROM m2.FinancialTransactions;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Inspect current indexes on Module 2 tables.
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_primary_key AS IsPrimaryKey
FROM sys.indexes AS i
WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'm2'
  AND i.name IS NOT NULL
ORDER BY TableName, IndexName;
GO

-- 2. Baseline query before creating a supporting date index.
SELECT TOP 100
    TransactionID,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
ORDER BY TransactionDate DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 3. Simple single-column index.
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_TransactionDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_TransactionDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_FinancialTransactions_TransactionDate'
      AND s.object_id = OBJECT_ID('m2.FinancialTransactions')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.FinancialTransactions.IX_M2_FinancialTransactions_TransactionDate;
END;
GO

CREATE INDEX IX_M2_FinancialTransactions_TransactionDate
ON m2.FinancialTransactions (TransactionDate);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 4. Re-run the same query and compare reads/plan shape.
SELECT TOP 100
    TransactionID,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
ORDER BY TransactionDate DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 5. Composite covering index for currency + date reporting.
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_CurrencyDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_CurrencyDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_FinancialTransactions_CurrencyDate'
      AND s.object_id = OBJECT_ID('m2.FinancialTransactions')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.FinancialTransactions.IX_M2_FinancialTransactions_CurrencyDate;
END;
GO

CREATE INDEX IX_M2_FinancialTransactions_CurrencyDate
ON m2.FinancialTransactions (CurrencyCode, TransactionDate)
INCLUDE (Amount, Status, AccountID, TransactionType, ReferenceCode);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 6. Query that can benefit from the composite index.
SELECT TOP 100
    TransactionID,
    AccountID,
    TransactionDate,
    TransactionType,
    Amount,
    CurrencyCode,
    Status,
    ReferenceCode
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
  AND CurrencyCode = 'USD'
ORDER BY Amount DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 7. Join-supporting indexes.
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_AccountDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_AccountDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_FinancialTransactions_AccountDate'
      AND s.object_id = OBJECT_ID('m2.FinancialTransactions')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.FinancialTransactions.IX_M2_FinancialTransactions_AccountDate;
END;
GO

CREATE INDEX IX_M2_FinancialTransactions_AccountDate
ON m2.FinancialTransactions (AccountID, TransactionDate)
INCLUDE (Amount, CurrencyCode, Status);
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_Accounts_Counterparty'
      AND object_id = OBJECT_ID('m2.Accounts')
)
BEGIN
    DROP INDEX IX_M2_Accounts_Counterparty ON m2.Accounts;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats AS s
    WHERE s.name = 'IX_M2_Accounts_Counterparty'
      AND s.object_id = OBJECT_ID('m2.Accounts')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.indexes AS i
          WHERE i.object_id = s.object_id
            AND i.name = s.name
      )
)
BEGIN
    DROP STATISTICS m2.Accounts.IX_M2_Accounts_Counterparty;
END;
GO

CREATE INDEX IX_M2_Accounts_Counterparty
ON m2.Accounts (CounterpartyID)
INCLUDE (AccountNumber, CurrencyCode, AccountType);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 8. Join query after supporting indexes.
SELECT TOP 100
    cp.CounterpartyName,
    a.AccountNumber,
    t.TransactionDate,
    t.Amount,
    t.CurrencyCode,
    t.Status
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
WHERE t.TransactionDate >= '2026-06-01'
  AND t.TransactionDate < '2026-07-01'
  AND t.Status = 'Posted'
ORDER BY t.TransactionDate DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 9. Inspect index usage after running the demos.
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COALESCE(us.user_seeks, 0) AS UserSeeks,
    COALESCE(us.user_scans, 0) AS UserScans,
    COALESCE(us.user_lookups, 0) AS UserLookups,
    COALESCE(us.user_updates, 0) AS UserUpdates
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS us
    ON i.object_id = us.object_id
    AND i.index_id = us.index_id
    AND us.database_id = DB_ID()
WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'm2'
  AND i.name IS NOT NULL
ORDER BY TableName, IndexName;
GO
