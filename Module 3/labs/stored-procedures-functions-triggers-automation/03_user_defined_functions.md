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
-- m3.fn_CapitalAdequacyBand
-- m3.fn_SubmissionsByPeriod

-- Preview tables used in this lab.
SELECT TOP 5 * FROM m3.RegulatorySubmissions;
SELECT TOP 5 * FROM m3.Institutions;

-- Notes:
-- A scalar function returns one value.
-- A table-valued function returns a table result.
-- Functions are useful for reusable business logic inside SELECT queries.

-- 1. Create scalar function m3.fn_CapitalAdequacyBand.
-- Input parameter: @CapitalAdequacyRatio DECIMAL(9,4).
-- Return type: VARCHAR(30).
-- Business bands:
-- NULL = Not Applicable.
-- Below 10 = Below Minimum.
-- 10 to below 13 = Watchlist.
-- 13 to below 16 = Adequate.
-- 16 and above = Strong.

-- 2. Test the scalar function with direct values.
-- Use NULL, 9.5, 12.5, 14.5, and 17.0.
-- This confirms the business bands before applying the function to table rows.

-- 3. Use the scalar function in a SELECT.
-- Source table: m3.RegulatorySubmissions.
-- Return SubmissionID, InstitutionCode, ReportingPeriod, CapitalAdequacyRatio, and CapitalAdequacyBand.

-- 4. Create inline table-valued function m3.fn_SubmissionsByPeriod.
-- Input parameters: @StartPeriod DATE, @EndPeriod DATE.
-- Return submissions between the two dates.
-- Join m3.RegulatorySubmissions to m3.Institutions.
-- Include CapitalAdequacyBand by calling the scalar function.

-- 5. Use the table-valued function like a table.
-- Query m3.fn_SubmissionsByPeriod('2026-01-01', '2026-03-31').
-- ORDER BY note: sort by InstitutionCode and ReportingPeriod.

-- Practice tasks:

-- Practice 1. Test the scalar function directly.
-- Use values: NULL, 9.5, 11.5, 14.0, 17.0.

-- Practice 2. Query only Watchlist or Below Minimum submissions.
-- Use m3.fn_CapitalAdequacyBand in the WHERE clause or a derived query.

-- Practice 3. Run the table-valued function for February 2026 only.
-- Compare the result to the full period query.
