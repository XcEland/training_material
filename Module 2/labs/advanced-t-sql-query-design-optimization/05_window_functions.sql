-- ============================================================
-- MODULE 2 LAB
-- FILE 05: WINDOW FUNCTIONS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- Window functions calculate across related rows without collapsing the result like GROUP BY does.
-- Focus on OVER, PARTITION BY, and ORDER BY.

-- Simple comparison A: GROUP BY reduces rows.
-- One output row is returned for each CurrencyCode.
SELECT
    CurrencyCode,
    SUM(Amount) AS PostedAmountForCurrency
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
GROUP BY CurrencyCode
ORDER BY CurrencyCode;
GO

-- Simple comparison B: PARTITION BY keeps all rows.
-- Each transaction row stays visible, and the currency total is added beside it.
SELECT TOP 10
    TransactionID,
    CurrencyCode,
    Amount,
    SUM(Amount) OVER (
        PARTITION BY CurrencyCode
    ) AS PostedAmountForCurrency
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
ORDER BY CurrencyCode, TransactionID;
GO

-- Warm-up 1. ROW_NUMBER with one ordered list.
-- ROW_NUMBER adds a sequence number without changing the rows returned.
SELECT TOP 10
    TransactionID,
    TransactionDate,
    Amount,
    ROW_NUMBER() OVER (
        ORDER BY TransactionDate, TransactionID
    ) AS RowNumber
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
ORDER BY TransactionDate, TransactionID;
GO

-- Warm-up 2. COUNT with OVER.
-- COUNT(*) OVER() adds the total row count beside each returned row.
SELECT TOP 10
    TransactionID,
    CurrencyCode,
    Amount,
    COUNT(*) OVER () AS TotalPostedRowsInResultSet
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
ORDER BY TransactionDate, TransactionID;
GO

-- Warm-up 3. PARTITION BY groups the window calculation.
-- The currency total is shown beside each transaction without collapsing the detail rows.
SELECT TOP 10
    TransactionID,
    CurrencyCode,
    Amount,
    SUM(Amount) OVER (
        PARTITION BY CurrencyCode
    ) AS PostedAmountForCurrency
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
ORDER BY CurrencyCode, TransactionDate, TransactionID;
GO

-- 1A. GROUP BY summary: one row per currency.
-- GROUP BY collapses each currency group into one summary row.
SELECT
    CurrencyCode,
    COUNT(*) AS PostedTransactionCount,
    SUM(Amount) AS PostedAmount
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
GROUP BY CurrencyCode
ORDER BY CurrencyCode;
GO

-- 1B. Window aggregate summary: keep transaction rows and add group-level values.
-- The detail rows remain visible while the currency totals are repeated beside each row.
SELECT TOP 30
    TransactionID,
    TransactionDate,
    CurrencyCode,
    Amount,
    COUNT(*) OVER (
        PARTITION BY CurrencyCode
    ) AS PostedTransactionCountForCurrency,
    SUM(Amount) OVER (
        PARTITION BY CurrencyCode
    ) AS PostedAmountForCurrency,
    AVG(Amount) OVER (
        PARTITION BY CurrencyCode
    ) AS AverageAmountForCurrency,
    MIN(Amount) OVER (
        PARTITION BY CurrencyCode
    ) AS SmallestAmountForCurrency,
    MAX(Amount) OVER (
        PARTITION BY CurrencyCode
    ) AS LargestAmountForCurrency
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
ORDER BY CurrencyCode, TransactionDate, TransactionID;
GO

-- 2. ROW_NUMBER: number transactions inside each account.
SELECT TOP 50
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionID,
    t.Amount,
    ROW_NUMBER() OVER (
        PARTITION BY a.AccountNumber
        ORDER BY t.TransactionDate, t.TransactionID
    ) AS TransactionSequence
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
WHERE t.Status = 'Posted'
ORDER BY a.AccountNumber, TransactionSequence;
GO

-- 3. RANK and DENSE_RANK: rank accounts by balance inside each currency.
-- RANK can leave gaps after ties. DENSE_RANK does not leave gaps after ties.
SELECT
    AccountNumber,
    AccountType,
    CurrencyCode,
    CurrentBalance,
    RANK() OVER (
        PARTITION BY CurrencyCode
        ORDER BY CurrentBalance DESC
    ) AS BalanceRank,
    DENSE_RANK() OVER (
        PARTITION BY CurrencyCode
        ORDER BY CurrentBalance DESC
    ) AS DenseBalanceRank
FROM m2.Accounts
ORDER BY CurrencyCode, BalanceRank, AccountNumber;
GO

-- 4. NTILE: split accounts into balance bands inside each currency.
-- NTILE(2) divides each currency partition into two ordered groups.
SELECT
    AccountNumber,
    AccountType,
    CurrencyCode,
    CurrentBalance,
    NTILE(2) OVER (
        PARTITION BY CurrencyCode
        ORDER BY CurrentBalance DESC
    ) AS BalanceBand
FROM m2.Accounts
ORDER BY CurrencyCode, BalanceBand, CurrentBalance DESC;
GO

-- 5. RANK: rank counterparties by monthly transaction value.
WITH MonthlyCounterpartyTotals AS (
    SELECT
        cp.CounterpartyName,
        DATEFROMPARTS(YEAR(t.TransactionDate), MONTH(t.TransactionDate), 1) AS MonthStart,
        SUM(t.Amount) AS TotalAmount
    FROM m2.FinancialTransactions AS t
    INNER JOIN m2.Accounts AS a
        ON t.AccountID = a.AccountID
    INNER JOIN m2.Counterparties AS cp
        ON a.CounterpartyID = cp.CounterpartyID
    WHERE t.Status = 'Posted'
    GROUP BY
        cp.CounterpartyName,
        DATEFROMPARTS(YEAR(t.TransactionDate), MONTH(t.TransactionDate), 1)
)
SELECT
    CounterpartyName,
    MonthStart,
    TotalAmount,
    RANK() OVER (
        PARTITION BY MonthStart
        ORDER BY TotalAmount DESC
    ) AS MonthlyRank
FROM MonthlyCounterpartyTotals
ORDER BY MonthStart DESC, MonthlyRank;
GO

-- 6. Running total: cumulative transaction value by account.
SELECT TOP 50
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionID,
    t.Amount,
    SUM(t.Amount) OVER (
        PARTITION BY a.AccountNumber
        ORDER BY t.TransactionDate, t.TransactionID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningAmount
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
WHERE t.Status = 'Posted'
ORDER BY a.AccountNumber, t.TransactionDate, t.TransactionID;
GO

-- 7. LAG and LEAD: compare each daily total with the previous and next daily totals.
WITH DailyTotals AS (
    SELECT
        t.CurrencyCode,
        t.TransactionDate,
        SUM(t.Amount) AS DailyAmount
    FROM m2.FinancialTransactions AS t
    WHERE t.Status = 'Posted'
    GROUP BY
        t.CurrencyCode,
        t.TransactionDate
)
SELECT TOP 40
    CurrencyCode,
    TransactionDate,
    DailyAmount,
    LAG(DailyAmount) OVER (
        PARTITION BY CurrencyCode
        ORDER BY TransactionDate
    ) AS PreviousDailyAmount,
    LEAD(DailyAmount) OVER (
        PARTITION BY CurrencyCode
        ORDER BY TransactionDate
    ) AS NextDailyAmount,
    DailyAmount - LAG(DailyAmount) OVER (
        PARTITION BY CurrencyCode
        ORDER BY TransactionDate
    ) AS ChangeFromPreviousDay
FROM DailyTotals
ORDER BY CurrencyCode, TransactionDate;
GO

-- 8. FIRST_VALUE: compare each account to the largest account balance in its currency.
SELECT
    AccountNumber,
    AccountType,
    CurrencyCode,
    CurrentBalance,
    FIRST_VALUE(AccountNumber) OVER (
        PARTITION BY CurrencyCode
        ORDER BY CurrentBalance DESC, AccountNumber
    ) AS LargestAccountInCurrency,
    FIRST_VALUE(CurrentBalance) OVER (
        PARTITION BY CurrencyCode
        ORDER BY CurrentBalance DESC, AccountNumber
    ) AS LargestBalanceInCurrency
FROM m2.Accounts
ORDER BY CurrencyCode, CurrentBalance DESC;
GO

-- 9. Window average: compare each transaction to the account average.
SELECT TOP 50
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionID,
    t.Amount,
    AVG(t.Amount) OVER (
        PARTITION BY a.AccountNumber
    ) AS AverageAmountForAccount,
    t.Amount - AVG(t.Amount) OVER (
        PARTITION BY a.AccountNumber
    ) AS DifferenceFromAccountAverage
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
WHERE t.Status = 'Posted'
ORDER BY a.AccountNumber, t.Amount DESC;
GO

-- 10. PERCENT_RANK and CUME_DIST: show relative balance position by currency.
-- These functions return relative ranking values between 0 and 1.
SELECT
    AccountNumber,
    AccountType,
    CurrencyCode,
    CurrentBalance,
    CAST(PERCENT_RANK() OVER (
        PARTITION BY CurrencyCode
        ORDER BY CurrentBalance
    ) AS DECIMAL(6,4)) AS PercentRankWithinCurrency,
    CAST(CUME_DIST() OVER (
        PARTITION BY CurrencyCode
        ORDER BY CurrentBalance
    ) AS DECIMAL(6,4)) AS CumulativeDistributionWithinCurrency
FROM m2.Accounts
ORDER BY CurrencyCode, CurrentBalance;
GO
