-- ============================================================
-- MODULE 3 LAB
-- FILE 03: USER-DEFINED FUNCTIONS - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- m3.Institutions fields: InstitutionCode, InstitutionName, InstitutionType, Country, IsActive
-- m3.RegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt

-- Function names:
-- m3.fn_DaysLate
-- m3.fn_CapitalAdequacyBand
-- m3.fn_LeverageRatio
-- m3.fn_SubmissionsByInstitution
-- m3.fn_SubmissionsByPeriod
-- m3.fn_InstitutionRiskSummary

-- Preview tables used in this lab.
SELECT TOP 5 * FROM m3.RegulatorySubmissions;
SELECT TOP 5 * FROM m3.Institutions;

-- Notes:
-- A scalar function returns one value.
-- An inline table-valued function returns a table from one SELECT statement.
-- A multi-statement table-valued function returns a table variable built inside the function.
-- Functions are useful for reusable business logic inside SELECT queries.

-- 1. Beginner scalar function: m3.fn_DaysLate.
-- Input parameters: @DueDate DATE and @SubmittedDate DATE.
-- Return type: INT.
-- Use DATEDIFF(DAY, @DueDate, @SubmittedDate).
-- Test it with direct dates first.
-- Then use it against m3.RegulatorySubmissions.
-- In this lab, assume each report is due 10 days after ReportingPeriod.

-- 2. Scalar function with business logic: m3.fn_CapitalAdequacyBand.
-- Input parameter: @CapitalAdequacyRatio DECIMAL(9,4).
-- Return type: VARCHAR(30).
-- Business bands:
-- NULL = Not Applicable.
-- Below 10 = Below Minimum.
-- 10 to below 13 = Watchlist.
-- 13 to below 16 = Adequate.
-- 16 and above = Strong.
-- Test direct values before applying it to table rows.

-- 3. Scalar function for a calculation: m3.fn_LeverageRatio.
-- Input parameters: @TotalAssets and @TotalLiabilities.
-- Return type: DECIMAL(9,4).
-- Calculate liabilities divided by assets.
-- Use NULLIF to avoid divide-by-zero errors.

-- 4. Inline table-valued function: m3.fn_SubmissionsByInstitution.
-- Input parameter: @InstitutionCode VARCHAR(20).
-- RETURNS TABLE AS RETURN (...one SELECT...).
-- Return submissions for one institution.
-- Usage: SELECT * FROM m3.fn_SubmissionsByInstitution('MCB').

-- 5. Inline table-valued function with date parameters: m3.fn_SubmissionsByPeriod.
-- Input parameters: @StartPeriod DATE and @EndPeriod DATE.
-- Return submissions between the two dates.
-- Join m3.RegulatorySubmissions to m3.Institutions.
-- Include CapitalAdequacyBand by calling the scalar function.

-- 6. Multi-statement table-valued function: m3.fn_InstitutionRiskSummary.
-- Input parameter: @Country VARCHAR(50) = NULL.
-- RETURNS @RiskSummary TABLE (...columns...).
-- INSERT summary rows into @RiskSummary.
-- RETURN the table variable.
-- Use it like a table in SELECT and JOIN statements.

-- Practice tasks:

-- Practice 1. Test m3.fn_DaysLate with a report submitted 5 days late.

-- Practice 2. Query only Watchlist or Below Minimum submissions.
-- Use m3.fn_CapitalAdequacyBand in a derived query.

-- Practice 3. Run m3.fn_SubmissionsByInstitution for 'LMB'.

-- Practice 4. Run m3.fn_SubmissionsByPeriod for February 2026 only.

-- Practice 5. Run m3.fn_InstitutionRiskSummary for South Africa.
