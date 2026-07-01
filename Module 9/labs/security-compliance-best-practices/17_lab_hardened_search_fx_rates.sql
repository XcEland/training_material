USE TrainingDB;
GO

CREATE OR ALTER PROCEDURE m2.usp_SearchFxRates
    @CurrencyCode VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    SET @CurrencyCode = UPPER(LTRIM(RTRIM(@CurrencyCode)));

    IF @CurrencyCode IS NULL OR LEN(@CurrencyCode) <> 3
    BEGIN
        RAISERROR('Invalid currency code.', 16, 1);
        RETURN;
    END;

    -- Static SQL is enough here, so no dynamic SQL is needed.
    SELECT CurrencyCode, RateDate, RateToLSL
    FROM m2.FxRates
    WHERE CurrencyCode = @CurrencyCode;
END;
GO
