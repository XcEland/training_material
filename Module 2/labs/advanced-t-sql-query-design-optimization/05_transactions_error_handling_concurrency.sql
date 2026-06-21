-- ============================================================
-- MODULE 2 LAB
-- FILE 05: TRANSACTIONS, ERROR HANDLING, AND CONCURRENCY
-- ============================================================

USE TrainingDB;
GO

SET XACT_ABORT ON;
GO

-- 1. Successful transaction with audit trail.
DECLARE @TransactionID BIGINT;
DECLARE @OldStatus VARCHAR(20);
DECLARE @OldAmount DECIMAL(18,2);

SELECT TOP 1
    @TransactionID = TransactionID,
    @OldStatus = Status,
    @OldAmount = Amount
FROM m2.FinancialTransactions
WHERE Status = 'Pending'
ORDER BY TransactionID;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE m2.FinancialTransactions
    SET Status = 'Posted'
    WHERE TransactionID = @TransactionID;

    INSERT INTO m2.TransactionAudit
        (TransactionID, ActionName, OldStatus, NewStatus, OldAmount, NewAmount)
    SELECT
        @TransactionID,
        'STATUS UPDATE',
        @OldStatus,
        Status,
        @OldAmount,
        Amount
    FROM m2.FinancialTransactions
    WHERE TransactionID = @TransactionID;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    INSERT INTO m2.ErrorLog (ProcedureName, ErrorNumber, ErrorMessage)
    VALUES ('Module2 successful transaction block', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;
GO

SELECT TOP 5 *
FROM m2.TransactionAudit
ORDER BY AuditID DESC;
GO

-- 2. Failed transaction that rolls back and logs the error.
DECLARE @RowsBefore INT = (
    SELECT COUNT(*)
    FROM m2.FinancialTransactions
    WHERE ReferenceCode = 'M2-BAD-ACCOUNT'
);

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO m2.FinancialTransactions
        (AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode)
    VALUES
        (999999, '2026-06-30', '2026-06-30', 'Deposit', 1000.00, 'LSL', 'Branch', 'Posted', 'M2-BAD-ACCOUNT');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    INSERT INTO m2.ErrorLog (ProcedureName, ErrorNumber, ErrorMessage)
    VALUES ('Module2 rollback demonstration', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;

SELECT
    @RowsBefore AS RowsBefore,
    COUNT(*) AS RowsAfterRollback
FROM m2.FinancialTransactions
WHERE ReferenceCode = 'M2-BAD-ACCOUNT';
GO

SELECT TOP 5
    ErrorTime,
    ProcedureName,
    ErrorNumber,
    ErrorMessage
FROM m2.ErrorLog
ORDER BY ErrorLogID DESC;
GO

-- 3. Concurrency pattern for discussion.
-- In production, use the smallest transaction scope that protects correctness.
-- UPDLOCK + HOLDLOCK can reserve the row/key range while business validation runs.
BEGIN TRANSACTION;

SELECT TOP 1
    AccountID,
    AccountNumber,
    CurrentBalance
FROM m2.Accounts WITH (UPDLOCK, HOLDLOCK)
WHERE AccountNumber = 'M2-LSL-0001';

-- Keep transactions short. This rollback is intentional for the lab demo.
ROLLBACK TRANSACTION;
GO
