-- ============================================================
-- MODULE 3 LAB
-- FILE 02: STORED PROCEDURE DESIGN PATTERNS
-- ============================================================

USE TrainingDB;
GO

CREATE OR ALTER PROCEDURE m3.usp_LogProcedureExecution
    @ProcedureName SYSNAME,
    @Status VARCHAR(20),
    @RowsAffected INT = NULL,
    @Message NVARCHAR(1000) = NULL,
    @ExecutionLogID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @ExecutionLogID IS NULL
    BEGIN
        INSERT INTO m3.ProcedureExecutionLog
            (ProcedureName, Status, RowsAffected, Message)
        VALUES
            (@ProcedureName, @Status, @RowsAffected, @Message);

        SET @ExecutionLogID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE m3.ProcedureExecutionLog
        SET
            EndedAt = SYSUTCDATETIME(),
            Status = @Status,
            RowsAffected = @RowsAffected,
            Message = @Message
        WHERE ExecutionLogID = @ExecutionLogID;
    END;
END;
GO

CREATE OR ALTER PROCEDURE m3.usp_GetInstitutionSubmissionSummary
    @InstitutionCode VARCHAR(20) = NULL,
    @StartPeriod DATE = NULL,
    @EndPeriod DATE = NULL,
    @RowsReturned INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionLogID INT;

    EXEC m3.usp_LogProcedureExecution
        @ProcedureName = 'm3.usp_GetInstitutionSubmissionSummary',
        @Status = 'Started',
        @Message = 'Summary procedure started',
        @ExecutionLogID = @ExecutionLogID OUTPUT;

    BEGIN TRY
        SELECT
            i.InstitutionCode,
            i.InstitutionName,
            s.ReportType,
            COUNT(*) AS SubmissionCount,
            SUM(s.TotalAssets) AS TotalAssets,
            SUM(s.TotalLiabilities) AS TotalLiabilities,
            AVG(s.CapitalAdequacyRatio) AS AvgCapitalAdequacyRatio,
            AVG(s.LiquidityCoverageRatio) AS AvgLiquidityCoverageRatio
        FROM m3.RegulatorySubmissions AS s
        INNER JOIN m3.Institutions AS i
            ON s.InstitutionCode = i.InstitutionCode
        WHERE (@InstitutionCode IS NULL OR s.InstitutionCode = @InstitutionCode)
          AND (@StartPeriod IS NULL OR s.ReportingPeriod >= @StartPeriod)
          AND (@EndPeriod IS NULL OR s.ReportingPeriod <= @EndPeriod)
        GROUP BY
            i.InstitutionCode,
            i.InstitutionName,
            s.ReportType
        ORDER BY
            i.InstitutionCode,
            s.ReportType;

        SET @RowsReturned = @@ROWCOUNT;

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_GetInstitutionSubmissionSummary',
            @Status = 'Succeeded',
            @RowsAffected = @RowsReturned,
            @Message = 'Summary procedure completed',
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        RETURN 0;
    END TRY
    BEGIN CATCH
        INSERT INTO m3.ErrorLog
            (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
        VALUES
            ('m3.usp_GetInstitutionSubmissionSummary', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_GetInstitutionSubmissionSummary',
            @Status = 'Failed',
            @RowsAffected = 0,
            @Message = 'Summary procedure failed; see m3.ErrorLog',
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        SET @RowsReturned = 0;
        RETURN 1;
    END CATCH;
END;
GO

DECLARE @RowsReturned INT;
DECLARE @ReturnCode INT;

EXEC @ReturnCode = m3.usp_GetInstitutionSubmissionSummary
    @InstitutionCode = NULL,
    @StartPeriod = '2026-01-01',
    @EndPeriod = '2026-12-31',
    @RowsReturned = @RowsReturned OUTPUT;

SELECT
    @ReturnCode AS ReturnCode,
    @RowsReturned AS RowsReturned;
GO

SELECT TOP 5
    ExecutionLogID,
    ProcedureName,
    Status,
    RowsAffected,
    Message,
    StartedAt,
    EndedAt
FROM m3.ProcedureExecutionLog
ORDER BY ExecutionLogID DESC;
GO
