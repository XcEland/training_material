-- ============================================================
-- MODULE 3 LAB
-- FILE 03: USER-DEFINED FUNCTIONS
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A user-defined function stores reusable business logic.
-- A scalar function returns one value.
-- An inline table-valued function returns a table from one SELECT statement.
-- A multi-statement table-valued function builds and returns a table variable.

-- ============================================================
-- 1. BEGINNER SCALAR FUNCTION: DAYS LATE
-- ============================================================

-- A scalar function returns one value.
-- Use case: calculate how many days late a report submission was.
CREATE OR ALTER FUNCTION m3.fn_DaysLate
(
    @DueDate DATE,
    @SubmittedDate DATE
)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @DueDate, @SubmittedDate);
END;
GO

-- Test the scalar function with direct values first.
SELECT
    m3.fn_DaysLate('2026-01-31', '2026-02-03') AS DaysLate;
GO

-- Use the scalar function in a table query.
-- In this lab, assume each report is due 10 days after the reporting period.
SELECT
    SubmissionID,
    InstitutionCode,
    ReportingPeriod,
    DATEADD(DAY, 10, ReportingPeriod) AS DueDate,
    CAST(SubmittedAt AS DATE) AS SubmittedDate,
    m3.fn_DaysLate(DATEADD(DAY, 10, ReportingPeriod), CAST(SubmittedAt AS DATE)) AS DaysLate
FROM m3.RegulatorySubmissions
ORDER BY SubmissionID;
GO

-- ============================================================
-- 2. SCALAR FUNCTION WITH BUSINESS LOGIC
-- ============================================================

-- This scalar function converts one capital adequacy ratio into a business band.
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

-- Test the business logic before using it in a table query.
SELECT
    m3.fn_CapitalAdequacyBand(NULL) AS NullRatioBand,
    m3.fn_CapitalAdequacyBand(9.5000) AS LowRatioBand,
    m3.fn_CapitalAdequacyBand(12.5000) AS WatchlistBand,
    m3.fn_CapitalAdequacyBand(14.5000) AS AdequateBand,
    m3.fn_CapitalAdequacyBand(17.0000) AS StrongBand;
GO

-- Use the scalar function against table rows.
SELECT
    SubmissionID,
    InstitutionCode,
    ReportingPeriod,
    CapitalAdequacyRatio,
    m3.fn_CapitalAdequacyBand(CapitalAdequacyRatio) AS CapitalAdequacyBand
FROM m3.RegulatorySubmissions
ORDER BY SubmissionID;
GO

-- ============================================================
-- 3. SCALAR FUNCTION FOR A CALCULATION
-- ============================================================

-- This function calculates liabilities divided by assets.
-- NULLIF prevents divide-by-zero errors.
CREATE OR ALTER FUNCTION m3.fn_LeverageRatio
(
    @TotalAssets DECIMAL(18,2),
    @TotalLiabilities DECIMAL(18,2)
)
RETURNS DECIMAL(9,4)
AS
BEGIN
    RETURN CAST(@TotalLiabilities / NULLIF(@TotalAssets, 0) AS DECIMAL(9,4));
END;
GO

SELECT
    SubmissionID,
    InstitutionCode,
    TotalAssets,
    TotalLiabilities,
    m3.fn_LeverageRatio(TotalAssets, TotalLiabilities) AS LeverageRatio
FROM m3.RegulatorySubmissions
ORDER BY SubmissionID;
GO

-- ============================================================
-- 4. INLINE TABLE-VALUED FUNCTION: ONE SELECT
-- ============================================================

-- An inline table-valued function returns a table from a single SELECT statement.
-- Use case: return all submissions for one institution.
CREATE OR ALTER FUNCTION m3.fn_SubmissionsByInstitution
(
    @InstitutionCode VARCHAR(20)
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
        ON i.InstitutionCode = s.InstitutionCode
    WHERE s.InstitutionCode = @InstitutionCode
);
GO

-- Use the inline table-valued function like a table.
SELECT *
FROM m3.fn_SubmissionsByInstitution('MCB')
ORDER BY ReportingPeriod;
GO

-- ============================================================
-- 5. INLINE TABLE-VALUED FUNCTION WITH DATE PARAMETERS
-- ============================================================

-- This function returns submissions in a supplied reporting period range.
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

SELECT *
FROM m3.fn_SubmissionsByPeriod('2026-01-01', '2026-03-31')
ORDER BY InstitutionCode, ReportingPeriod;
GO

-- ============================================================
-- 6. MULTI-STATEMENT TABLE-VALUED FUNCTION
-- ============================================================

-- A multi-statement table-valued function creates a table variable,
-- inserts rows into it, and then returns that table.
-- Use case: build a reusable institution risk summary.
CREATE OR ALTER FUNCTION m3.fn_InstitutionRiskSummary
(
    @Country VARCHAR(50) = NULL
)
RETURNS @RiskSummary TABLE
(
    InstitutionCode VARCHAR(20),
    InstitutionName VARCHAR(120),
    Country VARCHAR(50),
    SubmissionCount INT,
    AvgCapitalAdequacyRatio DECIMAL(9,4),
    AvgLiquidityCoverageRatio DECIMAL(9,4),
    RiskBand VARCHAR(30)
)
AS
BEGIN
    INSERT INTO @RiskSummary
        (InstitutionCode, InstitutionName, Country, SubmissionCount, AvgCapitalAdequacyRatio, AvgLiquidityCoverageRatio, RiskBand)
    SELECT
        i.InstitutionCode,
        i.InstitutionName,
        i.Country,
        COUNT(s.SubmissionID) AS SubmissionCount,
        AVG(s.CapitalAdequacyRatio) AS AvgCapitalAdequacyRatio,
        AVG(s.LiquidityCoverageRatio) AS AvgLiquidityCoverageRatio,
        m3.fn_CapitalAdequacyBand(AVG(s.CapitalAdequacyRatio)) AS RiskBand
    FROM m3.Institutions AS i
    LEFT JOIN m3.RegulatorySubmissions AS s
        ON s.InstitutionCode = i.InstitutionCode
    WHERE @Country IS NULL
       OR i.Country = @Country
    GROUP BY
        i.InstitutionCode,
        i.InstitutionName,
        i.Country;

    RETURN;
END;
GO

-- Use the multi-statement table-valued function like a table.
SELECT *
FROM m3.fn_InstitutionRiskSummary('Lesotho')
ORDER BY InstitutionCode;
GO

-- Join a table-valued function to another table.
-- This is one way functions support modular reporting logic.
SELECT
    r.InstitutionCode,
    r.InstitutionName,
    i.InstitutionType,
    r.SubmissionCount,
    r.RiskBand
FROM m3.fn_InstitutionRiskSummary(NULL) AS r
INNER JOIN m3.Institutions AS i
    ON i.InstitutionCode = r.InstitutionCode
ORDER BY
    r.Country,
    r.InstitutionCode;
GO
