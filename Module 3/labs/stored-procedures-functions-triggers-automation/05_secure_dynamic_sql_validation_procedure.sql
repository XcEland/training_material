-- ============================================================
-- MODULE 3 LAB
-- FILE 05: SECURE DYNAMIC SQL VALIDATION PROCEDURE
-- ============================================================

USE TrainingDB;
GO

CREATE OR ALTER PROCEDURE m3.usp_RunDataQualityChecks
    @TargetSchema SYSNAME,
    @TargetTable SYSNAME,
    @RuleSetName VARCHAR(50),
    @RunID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @FullTableName NVARCHAR(300),
        @RuleID INT,
        @RuleName VARCHAR(120),
        @ColumnName SYSNAME,
        @RuleType VARCHAR(30),
        @MinNumericValue DECIMAL(18,4),
        @MaxNumericValue DECIMAL(18,4),
        @Severity VARCHAR(20),
        @Sql NVARCHAR(MAX),
        @TotalViolations INT = 0,
        @ExecutionLogID INT;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.tables AS t
        INNER JOIN sys.schemas AS s
            ON t.schema_id = s.schema_id
        WHERE s.name = @TargetSchema
          AND t.name = @TargetTable
    )
    BEGIN
        THROW 52001, 'Target table does not exist.', 1;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM m3.ValidationRule
        WHERE RuleSetName = @RuleSetName
          AND TargetSchema = @TargetSchema
          AND TargetTable = @TargetTable
          AND IsActive = 1
    )
    BEGIN
        THROW 52002, 'No active validation rules found for the requested table and rule set.', 1;
    END;

    SET @FullTableName = QUOTENAME(@TargetSchema) + N'.' + QUOTENAME(@TargetTable);

    EXEC m3.usp_LogProcedureExecution
        @ProcedureName = 'm3.usp_RunDataQualityChecks',
        @Status = 'Started',
        @Message = 'Validation run started',
        @ExecutionLogID = @ExecutionLogID OUTPUT;

    BEGIN TRY
        INSERT INTO m3.ValidationRun
            (RuleSetName, TargetSchema, TargetTable, Status)
        VALUES
            (@RuleSetName, @TargetSchema, @TargetTable, 'Running');

        SET @RunID = SCOPE_IDENTITY();

        DECLARE rule_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT
                RuleID,
                RuleName,
                ColumnName,
                RuleType,
                MinNumericValue,
                MaxNumericValue,
                Severity
            FROM m3.ValidationRule
            WHERE RuleSetName = @RuleSetName
              AND TargetSchema = @TargetSchema
              AND TargetTable = @TargetTable
              AND IsActive = 1
            ORDER BY RuleID;

        OPEN rule_cursor;

        FETCH NEXT FROM rule_cursor
        INTO @RuleID, @RuleName, @ColumnName, @RuleType, @MinNumericValue, @MaxNumericValue, @Severity;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @RuleType = 'NOT_NULL'
            BEGIN
                SET @Sql = N'
                    INSERT INTO m3.ValidationViolation
                        (RunID, RuleID, SourceKey, Severity, ViolationMessage)
                    SELECT
                        @RunID,
                        @RuleID,
                        CAST(SubmissionID AS VARCHAR(50)),
                        @Severity,
                        CONCAT(@RuleName, '': '', @ColumnName, '' is required'')
                    FROM ' + @FullTableName + N'
                    WHERE ' + QUOTENAME(@ColumnName) + N' IS NULL;';
            END
            ELSE IF @RuleType = 'MIN_VALUE'
            BEGIN
                SET @Sql = N'
                    INSERT INTO m3.ValidationViolation
                        (RunID, RuleID, SourceKey, Severity, ViolationMessage)
                    SELECT
                        @RunID,
                        @RuleID,
                        CAST(SubmissionID AS VARCHAR(50)),
                        @Severity,
                        CONCAT(@RuleName, '': '', @ColumnName, '' is below minimum '', CONVERT(VARCHAR(50), @MinNumericValue))
                    FROM ' + @FullTableName + N'
                    WHERE ' + QUOTENAME(@ColumnName) + N' IS NOT NULL
                      AND TRY_CONVERT(DECIMAL(18,4), ' + QUOTENAME(@ColumnName) + N') < @MinNumericValue;';
            END
            ELSE IF @RuleType = 'MAX_VALUE'
            BEGIN
                SET @Sql = N'
                    INSERT INTO m3.ValidationViolation
                        (RunID, RuleID, SourceKey, Severity, ViolationMessage)
                    SELECT
                        @RunID,
                        @RuleID,
                        CAST(SubmissionID AS VARCHAR(50)),
                        @Severity,
                        CONCAT(@RuleName, '': '', @ColumnName, '' is above maximum '', CONVERT(VARCHAR(50), @MaxNumericValue))
                    FROM ' + @FullTableName + N'
                    WHERE ' + QUOTENAME(@ColumnName) + N' IS NOT NULL
                      AND TRY_CONVERT(DECIMAL(18,4), ' + QUOTENAME(@ColumnName) + N') > @MaxNumericValue;';
            END
            ELSE IF @RuleType = 'STATUS_IN'
            BEGIN
                SET @Sql = N'
                    INSERT INTO m3.ValidationViolation
                        (RunID, RuleID, SourceKey, Severity, ViolationMessage)
                    SELECT
                        @RunID,
                        @RuleID,
                        CAST(SubmissionID AS VARCHAR(50)),
                        @Severity,
                        CONCAT(@RuleName, '': status '', COALESCE(CONVERT(VARCHAR(50), ' + QUOTENAME(@ColumnName) + N'), ''NULL''), '' is not recognised'')
                    FROM ' + @FullTableName + N'
                    WHERE ' + QUOTENAME(@ColumnName) + N' IS NULL
                       OR ' + QUOTENAME(@ColumnName) + N' NOT IN (''Received'', ''Validated'', ''Rejected'', ''Submitted'');';
            END
            ELSE IF @RuleType = 'FK_INSTITUTION'
            BEGIN
                SET @Sql = N'
                    INSERT INTO m3.ValidationViolation
                        (RunID, RuleID, SourceKey, Severity, ViolationMessage)
                    SELECT
                        @RunID,
                        @RuleID,
                        CAST(src.SubmissionID AS VARCHAR(50)),
                        @Severity,
                        CONCAT(@RuleName, '': institution '', COALESCE(src.' + QUOTENAME(@ColumnName) + N', ''NULL''), '' is not in m3.Institutions'')
                    FROM ' + @FullTableName + N' AS src
                    WHERE src.' + QUOTENAME(@ColumnName) + N' IS NOT NULL
                      AND NOT EXISTS (
                          SELECT 1
                          FROM m3.Institutions AS i
                          WHERE i.InstitutionCode = src.' + QUOTENAME(@ColumnName) + N'
                      );';
            END
            ELSE
            BEGIN
                SET @Sql = NULL;
            END;

            IF @Sql IS NOT NULL
            BEGIN
                EXEC sp_executesql
                    @Sql,
                    N'@RunID INT, @RuleID INT, @Severity VARCHAR(20), @RuleName VARCHAR(120), @ColumnName SYSNAME, @MinNumericValue DECIMAL(18,4), @MaxNumericValue DECIMAL(18,4)',
                    @RunID = @RunID,
                    @RuleID = @RuleID,
                    @Severity = @Severity,
                    @RuleName = @RuleName,
                    @ColumnName = @ColumnName,
                    @MinNumericValue = @MinNumericValue,
                    @MaxNumericValue = @MaxNumericValue;
            END;

            FETCH NEXT FROM rule_cursor
            INTO @RuleID, @RuleName, @ColumnName, @RuleType, @MinNumericValue, @MaxNumericValue, @Severity;
        END;

        CLOSE rule_cursor;
        DEALLOCATE rule_cursor;

        SELECT
            @TotalViolations = COUNT(*)
        FROM m3.ValidationViolation
        WHERE RunID = @RunID;

        UPDATE m3.ValidationRun
        SET
            CompletedAt = SYSUTCDATETIME(),
            Status = CASE WHEN @TotalViolations = 0 THEN 'Passed' ELSE 'Completed' END,
            TotalViolations = @TotalViolations
        WHERE RunID = @RunID;

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_RunDataQualityChecks',
            @Status = 'Succeeded',
            @RowsAffected = @TotalViolations,
            @Message = 'Validation run completed',
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        SELECT
            @RunID AS RunID,
            @TotalViolations AS TotalViolations;

        SELECT
            vv.ViolationID,
            vv.SourceKey,
            vr.RuleName,
            vv.Severity,
            vv.ViolationMessage
        FROM m3.ValidationViolation AS vv
        INNER JOIN m3.ValidationRule AS vr
            ON vv.RuleID = vr.RuleID
        WHERE vv.RunID = @RunID
        ORDER BY
            CASE vv.Severity WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
            vv.ViolationID;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'rule_cursor') >= -1
        BEGIN
            CLOSE rule_cursor;
            DEALLOCATE rule_cursor;
        END;

        INSERT INTO m3.ErrorLog
            (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
        VALUES
            ('m3.usp_RunDataQualityChecks', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

        IF @RunID IS NOT NULL
        BEGIN
            UPDATE m3.ValidationRun
            SET
                CompletedAt = SYSUTCDATETIME(),
                Status = 'Failed'
            WHERE RunID = @RunID;
        END;

        EXEC m3.usp_LogProcedureExecution
            @ProcedureName = 'm3.usp_RunDataQualityChecks',
            @Status = 'Failed',
            @RowsAffected = 0,
            @Message = 'Validation run failed; see m3.ErrorLog',
            @ExecutionLogID = @ExecutionLogID OUTPUT;

        THROW;
    END CATCH;
END;
GO

DECLARE @RunID INT;

EXEC m3.usp_RunDataQualityChecks
    @TargetSchema = 'm3',
    @TargetTable = 'StagingRegulatorySubmissions',
    @RuleSetName = 'RegulatorySubmissionBasic',
    @RunID = @RunID OUTPUT;

SELECT @RunID AS LatestRunID;
GO
