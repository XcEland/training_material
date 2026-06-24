/* =============================================================================
   Module 9: Database Security, RBAC, and SQL Injection Prevention
-------------------------------------------------------------------------------
   This script starts with beginner concepts and moves toward safer production
   patterns:
   1. Create a small training schema.
   2. Create roles for least-privilege access.
   3. Demonstrate unsafe dynamic SQL.
   4. Replace it with parameterised sp_executesql.
   5. Add an audit trail table for sensitive access.
============================================================================= */

USE TrainingDB;
GO

IF SCHEMA_ID('m9') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA m9');
END;
GO

/* -----------------------------------------------------------------------------
   1. Training table with sensitive-looking data
   In production, this could represent customer, account, or regulatory data.
----------------------------------------------------------------------------- */
IF OBJECT_ID('m9.CustomerRiskProfile', 'U') IS NULL
BEGIN
    CREATE TABLE m9.CustomerRiskProfile
    (
        CustomerID       INT IDENTITY(1,1) PRIMARY KEY,
        CustomerName     NVARCHAR(100) NOT NULL,
        Country          NVARCHAR(50)  NOT NULL,
        RiskRating       NVARCHAR(20)  NOT NULL,
        ReviewStatus     NVARCHAR(30)  NOT NULL,
        CreatedAt        DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM m9.CustomerRiskProfile)
BEGIN
    INSERT INTO m9.CustomerRiskProfile (CustomerName, Country, RiskRating, ReviewStatus)
    VALUES
        ('Alpha Traders', 'Lesotho', 'Low', 'Approved'),
        ('Basotho Holdings', 'Lesotho', 'Medium', 'Pending'),
        ('Cross Border Finance', 'South Africa', 'High', 'Escalated'),
        ('Regional Exporters', 'Botswana', 'Medium', 'Approved');
END;
GO

/* -----------------------------------------------------------------------------
   2. Audit trail table
   This records who ran sensitive procedures and what parameter values were used.
----------------------------------------------------------------------------- */
IF OBJECT_ID('m9.SecurityAuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE m9.SecurityAuditLog
    (
        AuditID       BIGINT IDENTITY(1,1) PRIMARY KEY,
        EventTime     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        LoginName     SYSNAME   NOT NULL DEFAULT ORIGINAL_LOGIN(),
        UserName      SYSNAME   NOT NULL DEFAULT USER_NAME(),
        ProcedureName SYSNAME   NOT NULL,
        ActionTaken   NVARCHAR(100) NOT NULL,
        FilterValue   NVARCHAR(200) NULL
    );
END;
GO

/* -----------------------------------------------------------------------------
   3. Role-Based Access Control
   Least privilege means each role gets only the permissions it needs.
----------------------------------------------------------------------------- */
IF DATABASE_PRINCIPAL_ID('m9_read_only_analyst') IS NULL
    CREATE ROLE m9_read_only_analyst;
GO

IF DATABASE_PRINCIPAL_ID('m9_risk_reviewer') IS NULL
    CREATE ROLE m9_risk_reviewer;
GO

IF DATABASE_PRINCIPAL_ID('m9_app_executor') IS NULL
    CREATE ROLE m9_app_executor;
GO

-- Analysts may read the table but cannot modify it.
GRANT SELECT ON m9.CustomerRiskProfile TO m9_read_only_analyst;
GO

-- Risk reviewers can update the review status only, not every column.
GRANT SELECT ON m9.CustomerRiskProfile TO m9_risk_reviewer;
GRANT UPDATE (ReviewStatus) ON m9.CustomerRiskProfile TO m9_risk_reviewer;
GO

/* -----------------------------------------------------------------------------
   4. Unsafe example: string concatenation in dynamic SQL
   This procedure is intentionally vulnerable. Keep it for teaching only.
----------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE m9.usp_SearchRiskProfiles_Unsafe
    @Country NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sql NVARCHAR(MAX);

    -- Problem: user input is joined directly into the SQL command text.
    -- A malicious value could change the meaning of the query.
    SET @Sql = N'
        SELECT CustomerID, CustomerName, Country, RiskRating, ReviewStatus
        FROM m9.CustomerRiskProfile
        WHERE Country = ''' + @Country + N''';';

    EXEC (@Sql);
END;
GO

/* -----------------------------------------------------------------------------
   5. Safe example: sp_executesql with parameters
   The query text stays fixed and user values are passed separately.
----------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE m9.usp_SearchRiskProfiles_Safe
    @Country NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sql NVARCHAR(MAX) = N'
        SELECT CustomerID, CustomerName, Country, RiskRating, ReviewStatus
        FROM m9.CustomerRiskProfile
        WHERE Country = @CountryFilter;';

    INSERT INTO m9.SecurityAuditLog (ProcedureName, ActionTaken, FilterValue)
    VALUES ('m9.usp_SearchRiskProfiles_Safe', 'Search customer risk profile by country', @Country);

    EXEC sp_executesql
        @Sql,
        N'@CountryFilter NVARCHAR(50)',
        @CountryFilter = @Country;
END;
GO

/* -----------------------------------------------------------------------------
   6. Controlled update procedure
   Users execute the procedure instead of receiving broad table permissions.
----------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE m9.usp_UpdateRiskReviewStatus
    @CustomerID INT,
    @ReviewStatus NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF @ReviewStatus NOT IN ('Pending', 'Approved', 'Escalated', 'Rejected')
    BEGIN
        THROW 51000, 'Invalid review status supplied.', 1;
    END;

    UPDATE m9.CustomerRiskProfile
    SET ReviewStatus = @ReviewStatus
    WHERE CustomerID = @CustomerID;

    INSERT INTO m9.SecurityAuditLog (ProcedureName, ActionTaken, FilterValue)
    VALUES (
        'm9.usp_UpdateRiskReviewStatus',
        'Updated customer review status',
        CONCAT('CustomerID=', @CustomerID, '; ReviewStatus=', @ReviewStatus)
    );
END;
GO

-- Application/service accounts should execute approved procedures, not own tables.
GRANT EXECUTE ON m9.usp_SearchRiskProfiles_Safe TO m9_app_executor;
GRANT EXECUTE ON m9.usp_UpdateRiskReviewStatus TO m9_app_executor;
GO

/* -----------------------------------------------------------------------------
   7. Test calls
----------------------------------------------------------------------------- */
EXEC m9.usp_SearchRiskProfiles_Safe @Country = 'Lesotho';
GO

EXEC m9.usp_UpdateRiskReviewStatus @CustomerID = 2, @ReviewStatus = 'Approved';
GO

SELECT TOP (20)
    AuditID,
    EventTime,
    LoginName,
    UserName,
    ProcedureName,
    ActionTaken,
    FilterValue
FROM m9.SecurityAuditLog
ORDER BY AuditID DESC;
GO
