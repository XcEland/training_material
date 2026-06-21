-- ============================================================
-- MODULE 2 LAB
-- FILE 11: CONCURRENCY NOTES
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- Concurrency is about what happens when two users or jobs touch the same data at the same time.
-- Locking hints can protect critical business checks when concurrent activity is possible.

-- 1. Read the account normally.
SELECT
    AccountID,
    AccountNumber,
    CurrentBalance
FROM m2.Accounts
WHERE AccountNumber = 'M2-LSL-0001';
GO

-- 2. Locking pattern for a protected business check.
-- UPDLOCK asks SQL Server to take an update lock.
-- HOLDLOCK keeps the lock until the transaction ends.
-- This rollback is intentional for the lab demo.
BEGIN TRANSACTION;

SELECT
    AccountID,
    AccountNumber,
    CurrentBalance
FROM m2.Accounts WITH (UPDLOCK, HOLDLOCK)
WHERE AccountNumber = 'M2-LSL-0001';

ROLLBACK TRANSACTION;
GO

-- 3. Active-request query: show active sessions and requests.
SELECT
    session_id,
    status,
    command,
    blocking_session_id,
    wait_type,
    wait_time,
    wait_resource
FROM sys.dm_exec_requests
WHERE database_id = DB_ID()
ORDER BY session_id;
GO
