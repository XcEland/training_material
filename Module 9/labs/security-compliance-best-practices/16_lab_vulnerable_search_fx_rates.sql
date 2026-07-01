USE TrainingDB;
GO

CREATE PROCEDURE m2.usp_SearchFxRates
    @CurrencyCode VARCHAR(100)
AS
BEGIN
    DECLARE @Sql NVARCHAR(MAX);

    SET @Sql = '
    SELECT CurrencyCode, RateDate, RateToLSL
    FROM m2.FxRates
    WHERE CurrencyCode = ''' + @CurrencyCode + '''';

    EXEC (@Sql);
END;
GO
