-- ============================================================
-- MODULE 3 LAB
-- FILE 02: STORED PROCEDURE DESIGN PATTERNS - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- m3.Institutions fields: InstitutionCode, InstitutionName, InstitutionType, Country, IsActive
-- m3.RegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.StagingRegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.ProcedureExecutionLog fields: ExecutionLogID, ProcedureName, StartedAt, EndedAt, Status, RowsAffected, Message
-- m3.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage

-- Procedure names:
-- m3.usp_GetCountrySubmissionStats
-- m3.usp_ListSubmissionsByCountry
-- m3.usp_CleanStagingSubmissionNulls
-- m3.usp_GetCountryRiskReport
-- m3.usp_LogProcedureExecution
-- m3.usp_GetInstitutionSubmissionSummary

-- Preview tables used in this lab.
SELECT TOP 5 * FROM m3.Institutions;
SELECT TOP 5 * FROM m3.RegulatorySubmissions;
SELECT TOP 5 * FROM m3.StagingRegulatorySubmissions;
SELECT TOP 5 * FROM m3.ProcedureExecutionLog;
SELECT TOP 5 * FROM m3.ErrorLog;

-- Notes:
-- A stored procedure is a reusable database program.
-- Start with a normal SELECT query, then wrap it inside CREATE OR ALTER PROCEDURE.
-- Stored procedures can use variables, parameters, IF/ELSE, TRY/CATCH, output parameters, and return codes.
-- SET NOCOUNT ON avoids extra row-count messages from interfering with procedure output.

-- Common input parameter examples:
-- @Country
-- @InstitutionCode
-- @StartPeriod
-- @EndPeriod
-- @ReportType
-- @UploadedBy

-- 1. Start with a normal query.
-- For Lesotho institutions, find total institutions and average capital adequacy.
-- Join m3.Institutions to m3.RegulatorySubmissions.
-- Filter Country = 'Lesotho'.

-- 2. Turn the query into a basic stored procedure.
-- Procedure name: m3.usp_GetCountrySubmissionStats.
-- No parameters yet.
-- Hard-code Country = 'Lesotho'.
-- Execute with EXEC m3.usp_GetCountrySubmissionStats.

-- 3. Add an input parameter.
-- ALTER or CREATE OR ALTER the same procedure.
-- Input parameter: @Country VARCHAR(50) = 'Lesotho'.
-- Replace the hard-coded country with @Country.
-- Execute once with @Country = 'South Africa'.
-- Execute once without a parameter to use the default.

-- 4. Return multiple result sets.
-- Result set 1: institution count and average capital adequacy.
-- Result set 2: total submissions, total assets, and total liabilities.
-- Each SELECT statement ends with a semicolon.

-- 5. Use variables inside a stored procedure.
-- Declare @TotalInstitutions and @AvgCapitalAdequacyRatio.
-- Assign values using SELECT @Variable = aggregate_value.
-- PRINT the values with CONCAT.
-- Use COALESCE when printed values may be NULL.

-- 6. Control structures and basic parameter validation.
-- Procedure name: m3.usp_ListSubmissionsByCountry.
-- Input parameter: @Country VARCHAR(50) = 'Lesotho'.
-- IF the country does not exist, PRINT a message and RETURN.
-- ELSE return submissions for that country.

-- 7. Clean NULL values in staging data.
-- Procedure name: m3.usp_CleanStagingSubmissionNulls.
-- Input parameter: @DefaultStatus VARCHAR(20) = 'Received'.
-- IF SubmissionStatus is NULL, update it to @DefaultStatus.
-- IF SubmittedAt is NULL, update it to SYSUTCDATETIME().
-- Return RowsCleaned.
-- Keep this work on the staging table, not the main table.

-- 8. Report procedure with NULL handling.
-- Procedure name: m3.usp_GetCountryRiskReport.
-- Input parameters: @Country and @MinimumCapitalAdequacy.
-- IF @MinimumCapitalAdequacy is negative, THROW an error.
-- Use COALESCE to display NULL capital adequacy as 0 in the report only.
-- Use CASE to classify Not Reported, Below Minimum, or Meets Minimum.

-- 9. Reusable execution logging procedure.
-- Procedure name: m3.usp_LogProcedureExecution.
-- Input parameters: ProcedureName, Status, RowsAffected, Message.
-- Output parameter: @ExecutionLogID.
-- If @ExecutionLogID is NULL, insert a new log row.
-- If @ExecutionLogID has a value, update the existing log row.

-- 10. Full procedure: optional parameters, output, return code, TRY/CATCH.
-- Procedure name: m3.usp_GetInstitutionSubmissionSummary.
-- Input parameters:
-- @InstitutionCode VARCHAR(20) = NULL
-- @StartPeriod DATE = NULL
-- @EndPeriod DATE = NULL
-- Output parameter: @RowsReturned INT OUTPUT.
-- Return code: 0 for success, 1 for failure.
-- TRY block: validate dates, run the report, set row count, log success.
-- CATCH block: insert error details into m3.ErrorLog.
-- CATCH block: use ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), and ERROR_PROCEDURE().
-- CATCH block: PRINT Error Message, Error Number, Error Severity, Error State, Error Line, and Error Procedure.
-- CATCH block: log failure and return 1.

-- Practice tasks:

-- Practice 1. Execute m3.usp_GetCountrySubmissionStats for Lesotho and South Africa.

-- Practice 2. Execute m3.usp_GetCountryRiskReport with @MinimumCapitalAdequacy = 12.

-- Practice 3. Execute m3.usp_GetInstitutionSubmissionSummary for @InstitutionCode = 'MCB'.
-- Capture @RowsReturned and @ReturnCode.

-- Practice 4. Force an error by passing @StartPeriod after @EndPeriod.
-- Check m3.ErrorLog and m3.ProcedureExecutionLog afterward.
