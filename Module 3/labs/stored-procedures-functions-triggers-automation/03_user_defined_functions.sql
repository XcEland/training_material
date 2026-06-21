-- ============================================================
-- MODULE 3 LAB
-- FILE 03: USER-DEFINED FUNCTIONS
-- ============================================================

USE TrainingDB;
GO

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

SELECT
    SubmissionID,
    InstitutionCode,
    ReportingPeriod,
    CapitalAdequacyRatio,
    m3.fn_CapitalAdequacyBand(CapitalAdequacyRatio) AS CapitalAdequacyBand
FROM m3.RegulatorySubmissions
ORDER BY SubmissionID;
GO

SELECT *
FROM m3.fn_SubmissionsByPeriod('2026-01-01', '2026-03-31')
ORDER BY InstitutionCode, ReportingPeriod;
GO
