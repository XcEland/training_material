/* Intentionally vulnerable sample for Module 9 scanner practice. */

DECLARE @Country NVARCHAR(50) = N'Lesotho';
DECLARE @Sql NVARCHAR(MAX);

SET @Sql = N'SELECT * FROM m9.CustomerRiskProfile WHERE Country = ''' + @Country + N'''';

EXEC (@Sql);
