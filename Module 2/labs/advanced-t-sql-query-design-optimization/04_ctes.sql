-- ============================================================
-- MODULE 2 LAB
-- FILE 04: COMMON TABLE EXPRESSIONS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A CTE helps you name a temporary result set for the next SELECT.
-- Use CTEs to make multi-step reporting logic easier to read.
-- CTEs work well with aggregate functions when a report needs several logical steps.

-- The CTE creates a small named result set, then the SELECT reads from it.
WITH SampleCurrencies AS (
    SELECT 'USD' AS CurrencyCode
    UNION ALL
    SELECT 'EUR'
    UNION ALL
    SELECT 'LSL'
)
SELECT
    CurrencyCode
FROM SampleCurrencies;
GO

-- Warm-up 2. CTE that filters one table.
-- The CTE keeps only active accounts, then the final SELECT chooses what to display.
WITH ActiveAccounts AS (
    SELECT
        AccountNumber,
        AccountType,
        CurrencyCode,
        CurrentBalance
    FROM m2.Accounts
    WHERE AccountStatus = 'Active'
)
SELECT TOP 10
    AccountNumber,
    AccountType,
    CurrencyCode,
    CurrentBalance
FROM ActiveAccounts
ORDER BY AccountNumber;
GO

-- Warm-up 3. CTE that creates a calculated column.
-- The CTE gives the calculation a name so the final SELECT is easier to read.
WITH AccountBalanceLabels AS (
    SELECT
        AccountNumber,
        CurrencyCode,
        CurrentBalance,
        CASE
            WHEN CurrentBalance >= 10000 THEN 'High'
            ELSE 'Normal'
        END AS BalanceLabel
    FROM m2.Accounts
)
SELECT TOP 10
    AccountNumber,
    CurrencyCode,
    CurrentBalance,
    BalanceLabel
FROM AccountBalanceLabels
ORDER BY CurrentBalance DESC;
GO

-- 1. Simple CTE: name the filtered transaction set.
WITH PostedTransactions AS (
    SELECT
        TransactionID,
        AccountID,
        TransactionDate,
        Amount,
        CurrencyCode
    FROM m2.FinancialTransactions
    WHERE Status = 'Posted'
)
SELECT TOP 20
    TransactionID,
    TransactionDate,
    Amount,
    CurrencyCode
FROM PostedTransactions
ORDER BY TransactionDate DESC, TransactionID DESC;
GO

-- 2. CTE with aggregate functions: posted transaction profile by currency.
-- COUNT, SUM, AVG, MIN, and MAX summarize each currency group.
WITH CurrencyTransactionProfile AS (
    SELECT
        CurrencyCode,
        COUNT(*) AS TransactionCount,
        SUM(Amount) AS TotalAmount,
        AVG(Amount) AS AverageAmount,
        MIN(Amount) AS SmallestAmount,
        MAX(Amount) AS LargestAmount
    FROM m2.FinancialTransactions
    WHERE Status = 'Posted'
    GROUP BY CurrencyCode
)
SELECT
    CurrencyCode,
    TransactionCount,
    TotalAmount,
    AverageAmount,
    SmallestAmount,
    LargestAmount
FROM CurrencyTransactionProfile
ORDER BY CurrencyCode;
GO

-- 3. CTE with date grouping: monthly totals by currency.
WITH MonthlyCurrencyTotals AS (
    SELECT
        CurrencyCode,
        DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS MonthStart,
        COUNT(*) AS TransactionCount,
        SUM(Amount) AS TotalAmount
    FROM m2.FinancialTransactions
    WHERE Status = 'Posted'
    GROUP BY
        CurrencyCode,
        DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1)
)
SELECT
    CurrencyCode,
    MonthStart,
    TransactionCount,
    TotalAmount
FROM MonthlyCurrencyTotals
ORDER BY MonthStart DESC, CurrencyCode;
GO

-- 4. CTE followed by a join.
-- Aggregate first, then attach the counterparty name.
WITH AccountTotals AS (
    SELECT
        t.AccountID,
        COUNT(*) AS TransactionCount,
        SUM(t.Amount) AS TotalAmount
    FROM m2.FinancialTransactions AS t
    WHERE t.Status = 'Posted'
    GROUP BY t.AccountID
)
SELECT TOP 20
    cp.CounterpartyName,
    a.AccountNumber,
    acct.TransactionCount,
    acct.TotalAmount
FROM AccountTotals AS acct
INNER JOIN m2.Accounts AS a
    ON acct.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
ORDER BY acct.TotalAmount DESC;
GO

-- 5. Multiple CTEs: build a readable reporting pipeline.
WITH PostedTransactions AS (
    SELECT
        t.TransactionID,
        t.AccountID,
        t.TransactionDate,
        t.Amount,
        t.CurrencyCode
    FROM m2.FinancialTransactions AS t
    WHERE t.Status = 'Posted'
),
ConvertedTransactions AS (
    SELECT
        pt.TransactionID,
        pt.AccountID,
        pt.TransactionDate,
        pt.CurrencyCode,
        CAST(pt.Amount * fx.RateToLSL AS DECIMAL(18,2)) AS AmountLSL
    FROM PostedTransactions AS pt
    INNER JOIN m2.FxRates AS fx
        ON pt.CurrencyCode = fx.CurrencyCode
        AND pt.TransactionDate = fx.RateDate
),
MonthlyCounterpartyTotals AS (
    SELECT
        cp.CounterpartyName,
        DATEFROMPARTS(YEAR(ct.TransactionDate), MONTH(ct.TransactionDate), 1) AS MonthStart,
        COUNT(*) AS TransactionCount,
        SUM(ct.AmountLSL) AS TotalAmountLSL
    FROM ConvertedTransactions AS ct
    INNER JOIN m2.Accounts AS a
        ON ct.AccountID = a.AccountID
    INNER JOIN m2.Counterparties AS cp
        ON a.CounterpartyID = cp.CounterpartyID
    GROUP BY
        cp.CounterpartyName,
        DATEFROMPARTS(YEAR(ct.TransactionDate), MONTH(ct.TransactionDate), 1)
)
SELECT TOP 30
    CounterpartyName,
    MonthStart,
    TransactionCount,
    TotalAmountLSL
FROM MonthlyCounterpartyTotals
ORDER BY MonthStart DESC, TotalAmountLSL DESC;
GO

-- 6. Recursive CTE: generate a month calendar for reporting.
-- The first SELECT is the anchor row. The second SELECT adds the next month.
WITH MonthCalendar AS (
    SELECT CAST('2026-01-01' AS DATE) AS MonthStart

    UNION ALL

    SELECT DATEADD(MONTH, 1, MonthStart)
    FROM MonthCalendar
    WHERE MonthStart < '2026-06-01'
),
MonthlyPostedTotals AS (
    SELECT
        DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS MonthStart,
        COUNT(*) AS PostedTransactionCount,
        SUM(Amount) AS PostedAmount
    FROM m2.FinancialTransactions
    WHERE Status = 'Posted'
    GROUP BY DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1)
)
SELECT
    mc.MonthStart,
    COALESCE(mpt.PostedTransactionCount, 0) AS PostedTransactionCount,
    COALESCE(mpt.PostedAmount, 0) AS PostedAmount
FROM MonthCalendar AS mc
LEFT JOIN MonthlyPostedTotals AS mpt
    ON mc.MonthStart = mpt.MonthStart
ORDER BY mc.MonthStart
OPTION (MAXRECURSION 12);
GO
