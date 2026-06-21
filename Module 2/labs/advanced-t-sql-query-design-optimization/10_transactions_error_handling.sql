-- ============================================================
-- MODULE 2 LAB
-- FILE 10: TRANSACTIONS AND ERROR HANDLING
-- ============================================================

USE TrainingDB;
GO

SET XACT_ABORT ON;
GO

-- Notes:
-- A transaction groups changes so they succeed or fail together.
-- The examples cover rollback, commit, TRY/CATCH, and error logging.

-- 1. Simple transaction rollback.
-- The update happens inside the transaction, then ROLLBACK undoes it.
DECLARE @RollbackDemoTransactionID BIGINT;

SELECT TOP 1
    @RollbackDemoTransactionID = TransactionID
FROM m2.FinancialTransactions
WHERE Status = 'Pending'
ORDER BY TransactionID;

SELECT
    TransactionID,
    Status AS StatusBeforeRollbackDemo
FROM m2.FinancialTransactions
WHERE TransactionID = @RollbackDemoTransactionID;

BEGIN TRANSACTION;

UPDATE m2.FinancialTransactions
SET Status = 'Posted'
WHERE TransactionID = @RollbackDemoTransactionID;

SELECT
    TransactionID,
    Status AS StatusInsideTransaction
FROM m2.FinancialTransactions
WHERE TransactionID = @RollbackDemoTransactionID;

ROLLBACK TRANSACTION;

SELECT
    TransactionID,
    Status AS StatusAfterRollback
FROM m2.FinancialTransactions
WHERE TransactionID = @RollbackDemoTransactionID;
GO

-- 2. Successful transaction with audit trail.
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

-- 3. Failed transaction that rolls back and logs the error.
-- This intentionally uses a bad AccountID to trigger the foreign-key constraint.
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
