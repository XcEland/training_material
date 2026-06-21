-- ============================================================
-- MODULE 3 LAB
-- FILE 02: STORED PROCEDURE DESIGN PATTERNS - LIVE CODING SCAFFOLD
-- ============================================================

USE TrainingDB;
GO

-- Tables and fields:
-- m3.Institutions fields: InstitutionCode, InstitutionName, InstitutionType, Country, IsActive
-- m3.RegulatorySubmissions fields: SubmissionID, InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt
-- m3.ProcedureExecutionLog fields: ExecutionLogID, ProcedureName, StartedAt, EndedAt, Status, RowsAffected, Message
-- m3.ErrorLog fields: ErrorLogID, ErrorTime, ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage

-- Procedure names:
-- m3.usp_CountRegulatorySubmissions
-- m3.usp_ListSubmissionsByInstitution
-- m3.usp_LogProcedureExecution
-- m3.usp_GetInstitutionSubmissionSummary

-- Preview tables used in this lab.
SELECT TOP 5 * FROM m3.Institutions;
SELECT TOP 5 * FROM m3.RegulatorySubmissions;
SELECT TOP 5 * FROM m3.ProcedureExecutionLog;
SELECT TOP 5 * FROM m3.ErrorLog;

-- Notes:
-- A stored procedure is a reusable database program.
-- Stored procedures can accept input parameters, output parameters, and return codes.
-- TRY/CATCH captures errors so they can be logged.
-- SET NOCOUNT ON avoids extra row-count messages from interfering with procedure output.

-- 1. Basic stored procedure with no parameters.
-- Procedure name: m3.usp_CountRegulatorySubmissions.
-- Purpose: count all rows in m3.RegulatorySubmissions.
-- Execute with EXEC m3.usp_CountRegulatorySubmissions.

-- 2. Parameterized stored procedure.
-- Procedure name: m3.usp_ListSubmissionsByInstitution.
-- Input parameter: @InstitutionCode VARCHAR(20).
-- Purpose: list submissions for one institution.
-- Example execution: @InstitutionCode = 'MCB'.
-- ORDER BY note: sort by ReportingPeriod.

-- 3. Create m3.usp_LogProcedureExecution.
-- Purpose: write or update procedure execution log rows.
-- Input parameters: ProcedureName, Status, RowsAffected, Message.
-- Output parameter: ExecutionLogID.
-- If ExecutionLogID is NULL, insert a new log row.
-- If ExecutionLogID has a value, update the existing log row.

-- 4. Create m3.usp_GetInstitutionSubmissionSummary.
-- Purpose: return institution submission summary metrics.
-- Input parameters:
-- @InstitutionCode VARCHAR(20) = NULL
-- @StartPeriod DATE = NULL
-- @EndPeriod DATE = NULL
-- Output parameter: @RowsReturned INT OUTPUT.
-- Return code: 0 for success, 1 for failure.

-- 5. Start procedure logging.
-- Declare @ExecutionLogID.
-- Execute m3.usp_LogProcedureExecution with Status = 'Started'.

-- 6. Use TRY/CATCH.
-- TRY block: run the summary query, set row count, log success, return 0.
-- CATCH block: insert details into m3.ErrorLog, log failure, set RowsReturned to 0, return 1.

-- 7. Summary query logic.
-- Join m3.RegulatorySubmissions to m3.Institutions.
-- Use optional filters where parameter is NULL or matches the row.
-- Group by InstitutionCode, InstitutionName, and ReportType.
-- Return counts, sums, and averages.

-- 8. Execute the advanced procedure.
-- Declare @RowsReturned and @ReturnCode.
-- Execute procedure with a start and end period.
-- Return @ReturnCode and @RowsReturned.

-- 9. Review execution logs.
-- Query m3.ProcedureExecutionLog.
-- ORDER BY note: sort newest first by ExecutionLogID DESC.

-- Practice tasks:

-- Practice 1. Execute the summary procedure for one institution.
-- Use @InstitutionCode = 'MCB'.
-- Return the output row count and return code.

-- Practice 2. Execute the summary procedure for one reporting period range.
-- Use January 2026 only.
-- Compare returned rows with the all-period result.

-- Practice 3. Query failed procedure executions.
-- Source table: m3.ProcedureExecutionLog.
-- Filter Status = 'Failed'.
