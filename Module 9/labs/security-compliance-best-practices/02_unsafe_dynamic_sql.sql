USE TrainingDB;
GO

-- Unsafe example using the Module 2 exchange-rate table.
-- The currency value is joined into the SQL command text, which creates injection risk.
DECLARE @CurrencyCode VARCHAR(10) = 'USD';
DECLARE @Sql NVARCHAR(MAX);

SET @Sql = '
SELECT CurrencyCode, RateDate, RateToLSL
FROM m2.FxRates
WHERE CurrencyCode = ''' + @CurrencyCode + '''';

EXEC (@Sql);
GO
