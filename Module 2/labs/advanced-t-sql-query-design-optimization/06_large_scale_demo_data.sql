-- ============================================================
-- MODULE 2 LAB
-- FILE 06: LARGE-SCALE DEMO DATA
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- This script increases the transaction table to about 300,000 rows.
-- The extra rows make execution plans, logical reads, and index effects easier to compare.
-- The insert is set-based and repeatable; re-running it will not duplicate the demo rows.

SET NOCOUNT ON;
GO

DECLARE @TargetRows INT = 300000;
DECLARE @CurrentRows INT;
DECLARE @RowsToAdd INT;
DECLARE @ExistingDemoRows INT;

SELECT @CurrentRows = COUNT(*)
FROM m2.FinancialTransactions;

SELECT @ExistingDemoRows = COUNT(*)
FROM m2.FinancialTransactions
WHERE ReferenceCode LIKE 'M2X-%';

SET @RowsToAdd = @TargetRows - @CurrentRows;

IF @RowsToAdd > 0
BEGIN
    ;WITH n AS (
        SELECT TOP (@RowsToAdd)
            @ExistingDemoRows + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
        FROM sys.all_objects AS a
        CROSS JOIN sys.all_objects AS b
        CROSS JOIN sys.all_objects AS c
    ),
    prepared AS (
        SELECT
            rn,
            ((rn - 1) % 15) + 1 AS AccountID,
            DATEADD(DAY, -1 * (rn % 180), CAST('2026-06-30' AS DATE)) AS TransactionDate,
            CAST(50 + ((rn * 53) % 150000) AS DECIMAL(18,2)) AS Amount
        FROM n
    )
    INSERT INTO m2.FinancialTransactions
        (AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode)
    SELECT
        p.AccountID,
        p.TransactionDate,
        DATEADD(DAY, CASE WHEN p.rn % 7 = 0 THEN 1 ELSE 0 END, p.TransactionDate) AS ValueDate,
        CASE
            WHEN p.rn % 4 = 0 THEN 'Withdrawal'
            WHEN p.rn % 4 = 1 THEN 'Deposit'
            WHEN p.rn % 4 = 2 THEN 'Transfer'
            ELSE 'FX Settlement'
        END AS TransactionType,
        p.Amount,
        a.CurrencyCode,
        CASE
            WHEN p.rn % 5 = 0 THEN 'Branch'
            WHEN p.rn % 5 = 1 THEN 'Online Banking'
            WHEN p.rn % 5 = 2 THEN 'Mobile Banking'
            WHEN p.rn % 5 = 3 THEN 'SWIFT'
            ELSE 'Clearing'
        END AS Channel,
        CASE
            WHEN p.rn % 37 = 0 THEN 'Failed'
            WHEN p.rn % 19 = 0 THEN 'Pending'
            ELSE 'Posted'
        END AS Status,
        CONCAT('M2X-', RIGHT(CONCAT('000000000', p.rn), 9)) AS ReferenceCode
    FROM prepared AS p
    INNER JOIN m2.Accounts AS a
        ON p.AccountID = a.AccountID
    WHERE NOT EXISTS (
        SELECT 1
        FROM m2.FinancialTransactions AS existing
        WHERE existing.ReferenceCode = CONCAT('M2X-', RIGHT(CONCAT('000000000', p.rn), 9))
    );
END;
GO

SELECT
    COUNT(*) AS FinancialTransactionRows,
    MIN(TransactionDate) AS EarliestTransactionDate,
    MAX(TransactionDate) AS LatestTransactionDate
FROM m2.FinancialTransactions;
GO

SET NOCOUNT OFF;
GO
