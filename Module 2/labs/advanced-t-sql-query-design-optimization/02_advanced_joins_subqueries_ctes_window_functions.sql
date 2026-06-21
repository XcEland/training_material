-- ============================================================
-- MODULE 2 LAB
-- FILE 02: ADVANCED JOINS, SUBQUERIES, CTEs, WINDOW FUNCTIONS
-- ============================================================

USE TrainingDB;
GO

-- 1. Multi-table join: transactions with counterparty and FX conversion.
SELECT TOP 20
    t.TransactionID,
    cp.CounterpartyName,
    cp.Sector,
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionType,
    t.Amount,
    t.CurrencyCode,
    fx.RateToLSL,
    CAST(t.Amount * fx.RateToLSL AS DECIMAL(18,2)) AS AmountLSL
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
INNER JOIN m2.FxRates AS fx
    ON t.CurrencyCode = fx.CurrencyCode
    AND t.TransactionDate = fx.RateDate
WHERE t.Status = 'Posted'
ORDER BY t.TransactionDate DESC, t.TransactionID DESC;
GO

-- 2. LEFT JOIN: show accounts even when a day has no matching transaction.
SELECT
    a.AccountNumber,
    cp.CounterpartyName,
    COUNT(t.TransactionID) AS TransactionsOnDate,
    COALESCE(SUM(t.Amount), 0) AS TotalAmount
FROM m2.Accounts AS a
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
LEFT JOIN m2.FinancialTransactions AS t
    ON a.AccountID = t.AccountID
    AND t.TransactionDate = '2026-06-30'
GROUP BY
    a.AccountNumber,
    cp.CounterpartyName
ORDER BY a.AccountNumber;
GO

-- 3. Anti-join pattern: accounts with no failed transactions.
SELECT
    a.AccountNumber,
    cp.CounterpartyName
FROM m2.Accounts AS a
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
WHERE NOT EXISTS (
    SELECT 1
    FROM m2.FinancialTransactions AS t
    WHERE t.AccountID = a.AccountID
      AND t.Status = 'Failed'
);
GO

-- 4. Scalar subquery: compare each transaction with the average for its currency.
SELECT TOP 20
    t.TransactionID,
    t.CurrencyCode,
    t.Amount,
    (
        SELECT AVG(t2.Amount)
        FROM m2.FinancialTransactions AS t2
        WHERE t2.CurrencyCode = t.CurrencyCode
          AND t2.Status = 'Posted'
    ) AS AveragePostedAmountForCurrency
FROM m2.FinancialTransactions AS t
WHERE t.Status = 'Posted'
ORDER BY t.Amount DESC;
GO

-- 5. CTE: monthly counterparty totals.
WITH MonthlyCounterpartyTotals AS (
    SELECT
        cp.CounterpartyName,
        DATEFROMPARTS(YEAR(t.TransactionDate), MONTH(t.TransactionDate), 1) AS MonthStart,
        SUM(t.Amount) AS TotalAmount,
        COUNT(*) AS TransactionCount
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
SELECT TOP 30
    CounterpartyName,
    MonthStart,
    TransactionCount,
    TotalAmount
FROM MonthlyCounterpartyTotals
ORDER BY MonthStart DESC, TotalAmount DESC;
GO

-- 6. Window function: rank counterparties by monthly transaction value.
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

-- 7. Window function: running total by account.
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

-- 8. Window function: period-over-period comparison with LAG.
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
    DailyAmount - LAG(DailyAmount) OVER (
        PARTITION BY CurrencyCode
        ORDER BY TransactionDate
    ) AS ChangeFromPreviousDay
FROM DailyTotals
ORDER BY CurrencyCode, TransactionDate;
GO

-- 9. SET operator: posted dates with both USD and EUR activity.
SELECT TransactionDate
FROM m2.FinancialTransactions
WHERE CurrencyCode = 'USD'
  AND Status = 'Posted'
INTERSECT
SELECT TransactionDate
FROM m2.FinancialTransactions
WHERE CurrencyCode = 'EUR'
  AND Status = 'Posted'
ORDER BY TransactionDate;
GO
