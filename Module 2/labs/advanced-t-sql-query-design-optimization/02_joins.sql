-- ============================================================
-- MODULE 2 LAB
-- FILE 02: JOINS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- Examples progress from two-table joins to multi-table reporting joins.

-- 1. Two-table INNER JOIN: each account belongs to one counterparty.
-- INNER JOIN returns only rows where the join condition matches in both tables.
SELECT TOP 20
    a.AccountNumber,
    a.AccountType,
    a.CurrencyCode,
    cp.CounterpartyName,
    cp.Sector,
    cp.Country
FROM m2.Accounts AS a
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
ORDER BY a.AccountNumber;
GO

-- 2. Two-table INNER JOIN with transactions.
-- This shows transaction rows together with their account details.
SELECT TOP 20
    t.TransactionID,
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionType,
    t.Amount,
    t.CurrencyCode,
    t.Status
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
ORDER BY t.TransactionDate DESC, t.TransactionID DESC;
GO

-- 3. Two-table LEFT JOIN: keep all accounts even if no transaction matches the date.
-- LEFT JOIN keeps every row from the left table, then fills missing right-table values with NULL.
SELECT
    a.AccountNumber,
    a.AccountType,
    t.TransactionID,
    t.TransactionDate,
    t.Amount
FROM m2.Accounts AS a
LEFT JOIN m2.FinancialTransactions AS t
    ON a.AccountID = t.AccountID
    AND t.TransactionDate = '2026-06-30'
ORDER BY a.AccountNumber, t.TransactionID;
GO

-- 4. LEFT JOIN with aggregation.
-- COUNT(t.TransactionID) returns 0 when no transaction matched.
-- COALESCE changes NULL totals into 0 so the report is easier to read.
SELECT
    a.AccountNumber,
    COUNT(t.TransactionID) AS TransactionsOnDate,
    COALESCE(SUM(t.Amount), 0) AS TotalAmount
FROM m2.Accounts AS a
LEFT JOIN m2.FinancialTransactions AS t
    ON a.AccountID = t.AccountID
    AND t.TransactionDate = '2026-06-30'
GROUP BY a.AccountNumber
ORDER BY a.AccountNumber;
GO

-- 5. Three-table join: transactions, accounts, and counterparties.
-- This is a common reporting pattern: transaction facts plus descriptive dimensions.
SELECT TOP 20
    t.TransactionID,
    cp.CounterpartyName,
    cp.Sector,
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionType,
    t.Amount,
    t.CurrencyCode
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
WHERE t.Status = 'Posted'
ORDER BY t.TransactionDate DESC, t.TransactionID DESC;
GO

-- 6. Four-table join: add FX rates to convert each amount into LSL.
-- Notice that the FX join needs two conditions: currency and date.
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

-- 7. Anti-join pattern with NOT EXISTS.
-- This finds accounts that have no failed transactions.
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

-- 8. RIGHT JOIN: keep every account by placing Accounts on the right side.
-- RIGHT JOIN is less common than LEFT JOIN, but it is useful to recognise.
-- This returns the same kind of result as a LEFT JOIN with the table order reversed.
SELECT
    a.AccountNumber,
    a.AccountType,
    t.TransactionID,
    t.TransactionDate,
    t.Amount
FROM m2.FinancialTransactions AS t
RIGHT JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
    AND t.TransactionDate = '2026-06-30'
ORDER BY a.AccountNumber, t.TransactionID;
GO

-- 9. FULL OUTER JOIN: compare expected currencies against available FX rates.
-- FULL OUTER JOIN keeps unmatched rows from both sides.
WITH ExpectedCurrencies AS (
    SELECT *
    FROM (VALUES
        ('LSL'),
        ('ZAR'),
        ('USD'),
        ('EUR'),
        ('GBP'),
        ('JPY')
    ) AS c(CurrencyCode)
),
ActualRates AS (
    SELECT
        CurrencyCode,
        RateDate,
        RateToLSL
    FROM m2.FxRates
    WHERE RateDate = '2026-06-30'
)
SELECT
    COALESCE(ec.CurrencyCode, ar.CurrencyCode) AS CurrencyCode,
    ec.CurrencyCode AS ExpectedCurrency,
    ar.CurrencyCode AS RateCurrency,
    ar.RateDate,
    ar.RateToLSL,
    CASE
        WHEN ec.CurrencyCode IS NULL THEN 'Unexpected rate currency'
        WHEN ar.CurrencyCode IS NULL THEN 'Missing rate'
        ELSE 'Matched'
    END AS MatchStatus
FROM ExpectedCurrencies AS ec
FULL OUTER JOIN ActualRates AS ar
    ON ec.CurrencyCode = ar.CurrencyCode
ORDER BY CurrencyCode;
GO

-- 10. CROSS JOIN: generate a reporting grid of counterparties and currencies.
-- CROSS JOIN returns every combination from both inputs.
SELECT * FROM m2.Counterparties AS cp;
SELECT TOP 30
    cp.CounterpartyName,
    cp.Sector,
    c.CurrencyCode
FROM m2.Counterparties AS cp
CROSS JOIN (
    VALUES
        ('LSL'),
        ('ZAR'),
        ('USD'),
        ('EUR'),
        ('GBP')
) AS c(CurrencyCode)
ORDER BY cp.CounterpartyName, c.CurrencyCode;
GO

-- 11. Self-join pattern: compare accounts that belong to the same counterparty.
-- A self-join joins a table to itself using two aliases.
SELECT
    a1.CounterpartyID,
    a1.AccountNumber AS FirstAccount,
    a2.AccountNumber AS SecondAccount,
    a1.CurrencyCode AS FirstCurrency,
    a2.CurrencyCode AS SecondCurrency
FROM m2.Accounts AS a1
INNER JOIN m2.Accounts AS a2
    ON a1.CounterpartyID = a2.CounterpartyID
    AND a1.AccountID < a2.AccountID
ORDER BY a1.CounterpartyID, FirstAccount, SecondAccount;
GO
