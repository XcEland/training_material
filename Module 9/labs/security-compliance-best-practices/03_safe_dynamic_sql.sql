USE TrainingDB;
GO

-- Safer dynamic SQL using the same Module 2 exchange-rate table.
-- The SQL text stays fixed and the currency value is passed as data.
DECLARE @CurrencyCode VARCHAR(10) = 'USD';
DECLARE @Sql NVARCHAR(MAX);

SET @Sql = N'
SELECT CurrencyCode, RateDate, RateToLSL
FROM m2.FxRates
WHERE CurrencyCode = @CurrencyCode;
';

EXEC sp_executesql
    @Sql,
    N'@CurrencyCode VARCHAR(10)',
    @CurrencyCode = @CurrencyCode;
GO
