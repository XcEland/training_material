USE TrainingDB;
GO

IF SCHEMA_ID('reporting') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA reporting');
END;
GO

-- Reporting view for Module 2 transactions.
-- The raw counterparty name is masked before report users query it.
CREATE OR ALTER VIEW reporting.vw_TransactionSummaryMasked
AS
SELECT
    t.TransactionID,
    t.CurrencyCode,
    t.Amount,
    t.TransactionDate,
    LEFT(c.CounterpartyName, 1)
        + REPLICATE('*', CASE WHEN LEN(c.CounterpartyName) > 2 THEN LEN(c.CounterpartyName) - 2 ELSE 0 END)
        + RIGHT(c.CounterpartyName, 1) AS CounterpartyMasked
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS c
    ON a.CounterpartyID = c.CounterpartyID;
GO
