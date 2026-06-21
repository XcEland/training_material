-- ============================================================
-- MODULE 3 LAB
-- FILE 03: USER-DEFINED FUNCTIONS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A user-defined function stores reusable business logic.
-- A scalar function returns one value.
-- A table-valued function returns rows and columns like a table.

-- 1. Basic scalar function.
-- This function converts one capital adequacy ratio into a business band.
CREATE OR ALTER FUNCTION m3.fn_CapitalAdequacyBand
(
    @CapitalAdequacyRatio DECIMAL(9,4)
)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE @Band VARCHAR(30);

    SET @Band =
        CASE
            WHEN @CapitalAdequacyRatio IS NULL THEN 'Not Applicable'
            WHEN @CapitalAdequacyRatio < 10 THEN 'Below Minimum'
            WHEN @CapitalAdequacyRatio < 13 THEN 'Watchlist'
            WHEN @CapitalAdequacyRatio < 16 THEN 'Adequate'
            ELSE 'Strong'
        END;

    RETURN @Band;
END;
GO

-- 2. Test the scalar function with direct values.
-- This makes the input and output easy to understand before using the function in a table query.
SELECT
    m3.fn_CapitalAdequacyBand(NULL) AS NullRatioBand,
    m3.fn_CapitalAdequacyBand(9.5000) AS LowRatioBand,
    m3.fn_CapitalAdequacyBand(12.5000) AS WatchlistBand,
    m3.fn_CapitalAdequacyBand(14.5000) AS AdequateBand,
    m3.fn_CapitalAdequacyBand(17.0000) AS StrongBand;
GO

-- 3. Use the scalar function against table rows.
-- This applies the same business rule to every regulatory submission.
SELECT
    SubmissionID,
    InstitutionCode,
    ReportingPeriod,
    CapitalAdequacyRatio,
    m3.fn_CapitalAdequacyBand(CapitalAdequacyRatio) AS CapitalAdequacyBand
FROM m3.RegulatorySubmissions
ORDER BY SubmissionID;
GO

-- 4. Inline table-valued function.
-- This function returns all submissions in a supplied reporting period range.
CREATE OR ALTER FUNCTION m3.fn_SubmissionsByPeriod
(
    @StartPeriod DATE,
    @EndPeriod DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        s.SubmissionID,
        s.InstitutionCode,
        i.InstitutionName,
        s.ReportingPeriod,
        s.ReportType,
        s.TotalAssets,
        s.TotalLiabilities,
        s.CapitalAdequacyRatio,
        m3.fn_CapitalAdequacyBand(s.CapitalAdequacyRatio) AS CapitalAdequacyBand,
        s.LiquidityCoverageRatio,
        s.SubmissionStatus
    FROM m3.RegulatorySubmissions AS s
    INNER JOIN m3.Institutions AS i
        ON s.InstitutionCode = i.InstitutionCode
    WHERE s.ReportingPeriod >= @StartPeriod
      AND s.ReportingPeriod <= @EndPeriod
);
GO

-- 5. Use the table-valued function like a table.
SELECT *
FROM m3.fn_SubmissionsByPeriod('2026-01-01', '2026-03-31')
ORDER BY InstitutionCode, ReportingPeriod;
GO
