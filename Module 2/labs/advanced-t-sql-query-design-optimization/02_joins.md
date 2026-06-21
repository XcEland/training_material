-- ============================================================
-- MODULE 2 LAB
-- FILE 02: JOINS
-- ============================================================

USE TrainingDB;
GO

-- Tables:
-- Schema: m2
-- Tables and fields:
-- m2.Counterparties fields: CounterpartyID, CounterpartyName, Sector, Country, RiskRating
-- m2.Accounts fields: AccountID, AccountNumber, CounterpartyID, AccountType, CurrencyCode, CurrentBalance, OpenedDate, AccountStatus
-- m2.FxRates fields: CurrencyCode, RateDate, RateToLSL
-- m2.FinancialTransactions fields: TransactionID, AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode, CreatedAt
-- m2.StagingTransactions fields: ReferenceCode, AccountNumber, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status
-- m2.MonthlyTransactionSummary fields: SummaryMonth, CurrencyCode, PostedTransactionCount, PostedAmount, LoadedAt
-- m2.TransactionAudit fields: AuditID, TransactionID, ActionName, OldStatus, NewStatus, OldAmount, NewAmount, ChangedBy, ChangedAt
-- m2.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorMessage
-- m2.OptimizationBenchmark fields: BenchmarkID, QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes, CapturedAt

-- Useful join keys:
-- m2.Accounts.CounterpartyID = m2.Counterparties.CounterpartyID
-- m2.FinancialTransactions.AccountID = m2.Accounts.AccountID
-- m2.FinancialTransactions.CurrencyCode = m2.FxRates.CurrencyCode
-- m2.FinancialTransactions.TransactionDate = m2.FxRates.RateDate
-- self-join key example: m2.Accounts.CounterpartyID = m2.Accounts.CounterpartyID using two aliases

-- Preview the tables used in this joins lab.
SELECT TOP 5 * FROM m2.Accounts AS a;
SELECT TOP 5 * FROM m2.Counterparties AS cp;
SELECT TOP 5 * FROM m2.FinancialTransactions AS t;
SELECT TOP 5 * FROM m2.FxRates AS fx;

-- Notes:
-- Examples progress from two-table joins to multi-table reporting joins.
-- ORDER BY controls the display order of the final result set.
-- Use ORDER BY to make join output predictable and easier to compare.

-- 1. Two-table INNER JOIN: each account belongs to one counterparty.
-- INNER JOIN returns only rows where the join condition matches in both tables.
-- Use m2.Accounts AS a and m2.Counterparties AS cp.
-- Output fields: a.AccountNumber, a.AccountType, a.CurrencyCode, cp.CounterpartyName, cp.Sector, cp.Country.
-- ORDER BY note: sort by a.AccountNumber.

-- 2. Two-table INNER JOIN with transactions.
-- This shows transaction rows together with their account details.
-- Use m2.FinancialTransactions AS t and m2.Accounts AS a.
-- Output fields: t.TransactionID, a.AccountNumber, t.TransactionDate, t.TransactionType, t.Amount, t.CurrencyCode, t.Status.
-- ORDER BY note: sort by t.TransactionDate DESC, then t.TransactionID DESC.

-- 3. Two-table LEFT JOIN: keep all accounts even if no transaction matches the date.
-- LEFT JOIN keeps every row from the left table, then fills missing right-table values with NULL.
-- Use m2.Accounts AS a as the left table.
-- Match transactions on AccountID and TransactionDate = '2026-06-30'.
-- Output fields: a.AccountNumber, a.AccountType, t.TransactionID, t.TransactionDate, t.Amount.
-- ORDER BY note: sort by a.AccountNumber, then t.TransactionID.

-- 4. LEFT JOIN with aggregation.
-- COUNT(t.TransactionID) returns 0 when no transaction matched.
-- COALESCE changes NULL totals into 0 so the report is easier to read.
-- Group by a.AccountNumber.
-- Output fields: a.AccountNumber, TransactionsOnDate, TotalAmount.
-- ORDER BY note: sort by a.AccountNumber.

-- 5. Three-table join: transactions, accounts, and counterparties.
-- This is a common reporting pattern: transaction facts plus descriptive dimensions.
-- Use m2.FinancialTransactions AS t, m2.Accounts AS a, and m2.Counterparties AS cp.
-- Filter to posted transactions with t.Status = 'Posted'.

-- 6. Four-table join: add FX rates to convert each amount into LSL.
-- Notice that the FX join needs two conditions: currency and date.
-- Join keys: t.CurrencyCode = fx.CurrencyCode and t.TransactionDate = fx.RateDate.
-- Calculated value: CAST(t.Amount * fx.RateToLSL AS DECIMAL(18,2)) AS AmountLSL.

-- 7. Anti-join pattern with NOT EXISTS.
-- This finds accounts that have no failed transactions.
-- Use NOT EXISTS against m2.FinancialTransactions where Status = 'Failed'.

-- 8. RIGHT JOIN: keep every account by placing Accounts on the right side.
-- RIGHT JOIN is less common than LEFT JOIN, but it is useful to recognise.
-- This returns the same kind of result as a LEFT JOIN with the table order reversed.
-- Use m2.FinancialTransactions AS t RIGHT JOIN m2.Accounts AS a.
-- Match transactions on AccountID and TransactionDate = '2026-06-30'.
-- ORDER BY note: sort by a.AccountNumber, then t.TransactionID.

-- 9. FULL OUTER JOIN: compare expected currencies against available FX rates.
-- FULL OUTER JOIN keeps unmatched rows from both sides.
-- ExpectedCurrencies values: LSL, ZAR, USD, EUR, GBP, JPY.
-- ActualRates source: m2.FxRates where RateDate = '2026-06-30'.
-- Match key: ExpectedCurrencies.CurrencyCode = ActualRates.CurrencyCode.
-- Output fields: CurrencyCode, ExpectedCurrency, RateCurrency, RateDate, RateToLSL, MatchStatus.
-- ORDER BY note: sort by CurrencyCode.

-- 10. CROSS JOIN: generate a reporting grid of counterparties and currencies.
-- CROSS JOIN returns every combination from both inputs.
-- Use m2.Counterparties AS cp and inline currency values LSL, ZAR, USD, EUR, GBP.
-- Output fields: cp.CounterpartyName, cp.Sector, CurrencyCode.
-- ORDER BY note: sort by cp.CounterpartyName, then CurrencyCode.

-- 11. Self-join pattern: compare accounts that belong to the same counterparty.
-- A self-join joins a table to itself using two aliases.
-- Use m2.Accounts AS a1 and m2.Accounts AS a2.
-- Match on a1.CounterpartyID = a2.CounterpartyID.
-- Prevent duplicate/reversed pairs with a1.AccountID < a2.AccountID.
-- ORDER BY note: sort by CounterpartyID, then FirstAccount, then SecondAccount.
