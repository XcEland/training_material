-- ============================================================
-- MODULE 2 LAB
-- FILE 08: MERGE OPERATIONS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- MERGE compares a source dataset with a target table.
-- Source rows are previewed and classified before the MERGE operation runs.

-- 1. Review staging rows before loading.
SELECT
    ReferenceCode,
    AccountNumber,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
FROM m2.StagingTransactions
ORDER BY ReferenceCode;
GO

-- 2. Show which staging rows already exist in the target table.
SELECT
    s.ReferenceCode,
    s.AccountNumber,
    CASE
        WHEN t.TransactionID IS NULL THEN 'New row'
        ELSE 'Existing row'
    END AS MergeActionPreview,
    t.TransactionID AS ExistingTransactionID
FROM m2.StagingTransactions AS s
LEFT JOIN m2.FinancialTransactions AS t
    ON s.ReferenceCode = t.ReferenceCode
ORDER BY s.ReferenceCode;
GO

-- 3. Clean and validate source rows before MERGE.
WITH CleanStage AS (
    SELECT
        s.ReferenceCode,
        a.AccountID,
        s.TransactionDate,
        s.ValueDate,
        s.TransactionType,
        s.Amount,
        s.CurrencyCode,
        s.Channel,
        s.Status
    FROM m2.StagingTransactions AS s
    INNER JOIN m2.Accounts AS a
        ON s.AccountNumber = a.AccountNumber
    WHERE s.Amount > 0
)
SELECT *
FROM CleanStage
ORDER BY ReferenceCode;
GO

-- 4. MERGE staging data into the transaction table.
DECLARE @MergeResults TABLE (
    MergeAction VARCHAR(10),
    ReferenceCode VARCHAR(40),
    TransactionID BIGINT NULL
);

WITH CleanStage AS (
    SELECT
        s.ReferenceCode,
        a.AccountID,
        s.TransactionDate,
        s.ValueDate,
        s.TransactionType,
        s.Amount,
        s.CurrencyCode,
        s.Channel,
        s.Status
    FROM m2.StagingTransactions AS s
    INNER JOIN m2.Accounts AS a
        ON s.AccountNumber = a.AccountNumber
    WHERE s.Amount > 0
)
MERGE m2.FinancialTransactions AS target
USING CleanStage AS source
    ON target.ReferenceCode = source.ReferenceCode
WHEN MATCHED THEN
    UPDATE SET
        target.AccountID = source.AccountID,
        target.TransactionDate = source.TransactionDate,
        target.ValueDate = source.ValueDate,
        target.TransactionType = source.TransactionType,
        target.Amount = source.Amount,
        target.CurrencyCode = source.CurrencyCode,
        target.Channel = source.Channel,
        target.Status = source.Status
WHEN NOT MATCHED THEN
    INSERT
        (AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode)
    VALUES
        (source.AccountID, source.TransactionDate, source.ValueDate, source.TransactionType, source.Amount, source.CurrencyCode, source.Channel, source.Status, source.ReferenceCode)
OUTPUT
    CASE
        WHEN deleted.TransactionID IS NULL THEN 'INSERT'
        ELSE 'UPDATE'
    END,
    inserted.ReferenceCode,
    inserted.TransactionID
INTO @MergeResults;

SELECT *
FROM @MergeResults
ORDER BY ReferenceCode;
GO

-- 5. Confirm the staging references now exist in the target table.
SELECT
    t.ReferenceCode,
    a.AccountNumber,
    t.TransactionDate,
    t.Amount,
    t.CurrencyCode,
    t.Status
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
WHERE t.ReferenceCode IN (
    SELECT ReferenceCode
    FROM m2.StagingTransactions
)
ORDER BY t.ReferenceCode;
GO
