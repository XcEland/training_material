USE TrainingDB;
GO

-- Object names cannot be normal parameters, so validate them first.
-- This uses tables already introduced in Modules 2 and 6.
DECLARE @TableName SYSNAME = 'FxRates';
DECLARE @SchemaName SYSNAME;
DECLARE @SafeTableName SYSNAME;
DECLARE @SafeSchemaName SYSNAME;
DECLARE @Sql NVARCHAR(MAX);

IF @TableName = 'FxRates'
    SET @SchemaName = 'm2';
ELSE IF @TableName = 'FinancialTransactions'
    SET @SchemaName = 'm2';
ELSE IF @TableName = 'ReportDistributionAudit'
    SET @SchemaName = 'm6';
ELSE
BEGIN
    RAISERROR('Table name is not approved.', 16, 1);
    RETURN;
END;

SET @SafeTableName = QUOTENAME(@TableName);
SET @SafeSchemaName = QUOTENAME(@SchemaName);

-- QUOTENAME protects the approved schema and table names before they are joined.
SET @Sql = N'SELECT TOP (20) * FROM '
    + @SafeSchemaName + N'.' + @SafeTableName + N';'; -- security-scan: ignore

EXEC sp_executesql @Sql;
GO
