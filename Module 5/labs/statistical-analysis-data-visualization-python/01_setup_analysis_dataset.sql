-- ============================================================
-- MODULE 5 LAB
-- FILE 01: SETUP STATISTICAL ANALYSIS DATASET
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm5')
BEGIN
    EXEC('CREATE SCHEMA m5');
END;
GO

IF OBJECT_ID('m5.AnalysisReportRun', 'U') IS NOT NULL DROP TABLE m5.AnalysisReportRun;
IF OBJECT_ID('m5.DailyFinancialIndicators', 'U') IS NOT NULL DROP TABLE m5.DailyFinancialIndicators;
GO

CREATE TABLE m5.DailyFinancialIndicators (
    ObservationID INT IDENTITY(1,1) PRIMARY KEY,
    ObservationDate DATE NOT NULL,
    InstitutionCode VARCHAR(20) NOT NULL,
    InstitutionName VARCHAR(120) NOT NULL,
    Region VARCHAR(40) NOT NULL,
    InstitutionType VARCHAR(40) NOT NULL,
    TotalDepositsLSL DECIMAL(18,2) NOT NULL,
    TotalLoansLSL DECIMAL(18,2) NOT NULL,
    LiquidityRatio DECIMAL(9,4) NOT NULL,
    CapitalAdequacyRatio DECIMAL(9,4) NOT NULL,
    NplRatio DECIMAL(9,4) NOT NULL,
    TransactionVolume INT NOT NULL,
    TransactionValueLSL DECIMAL(18,2) NOT NULL,
    CreditGrowthRate DECIMAL(9,4) NOT NULL,
    InflationRate DECIMAL(9,4) NOT NULL,
    InterbankRate DECIMAL(9,4) NOT NULL,
    StressFlag BIT NOT NULL
);
GO

CREATE TABLE m5.AnalysisReportRun (
    ReportRunID INT IDENTITY(1,1) PRIMARY KEY,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    AnalystName VARCHAR(120) NULL,
    ObservationRows INT NOT NULL,
    MeanLiquidityRatio DECIMAL(9,4) NULL,
    MeanNplRatio DECIMAL(9,4) NULL,
    ModelAccuracy DECIMAL(9,4) NULL,
    Notes NVARCHAR(1000) NULL
);
GO

WITH Dates AS (
    SELECT 0 AS DayNumber, CAST('2026-04-01' AS DATE) AS ObservationDate
    UNION ALL
    SELECT
        DayNumber + 1,
        DATEADD(DAY, 1, ObservationDate)
    FROM Dates
    WHERE DayNumber < 59
),
Institutions AS (
    SELECT *
    FROM (VALUES
        ('CBL', 'Central Bank Liquidity Desk', 'Maseru', 'Central Bank', 920000000.00, 310000000.00, 0.3450, 0.2180, 0.0200, 1),
        ('MCB', 'Maseru Commercial Bank', 'Maseru', 'Commercial Bank', 610000000.00, 520000000.00, 0.2780, 0.1610, 0.0480, 2),
        ('LMB', 'Leribe Microfinance Bank', 'Leribe', 'Microfinance', 185000000.00, 171000000.00, 0.2350, 0.1390, 0.0730, 3),
        ('QFB', 'Quthing Finance Bank', 'Quthing', 'Commercial Bank', 275000000.00, 251000000.00, 0.2420, 0.1480, 0.0670, 4),
        ('BDB', 'Butha-Buthe Development Bank', 'Butha-Buthe', 'Development Bank', 330000000.00, 298000000.00, 0.2550, 0.1540, 0.0610, 5),
        ('MFI', 'Mafeteng Inclusion Finance', 'Mafeteng', 'Microfinance', 145000000.00, 139000000.00, 0.2180, 0.1280, 0.0860, 6)
    ) AS i(InstitutionCode, InstitutionName, Region, InstitutionType, BaseDeposits, BaseLoans, BaseLiquidity, BaseCapital, BaseNpl, InstitutionWeight)
),
Prepared AS (
    SELECT
        d.ObservationDate,
        d.DayNumber,
        i.InstitutionCode,
        i.InstitutionName,
        i.Region,
        i.InstitutionType,
        i.BaseDeposits,
        i.BaseLoans,
        i.BaseLiquidity,
        i.BaseCapital,
        i.BaseNpl,
        i.InstitutionWeight,
        CAST(0.0470 + ((d.DayNumber % 11) * 0.0007) AS DECIMAL(9,4)) AS InflationRate,
        CAST(0.0820 + ((d.DayNumber % 7) * 0.0009) AS DECIMAL(9,4)) AS InterbankRate
    FROM Dates AS d
    CROSS JOIN Institutions AS i
),
Calculated AS (
    SELECT
        ObservationDate,
        InstitutionCode,
        InstitutionName,
        Region,
        InstitutionType,
        CAST(BaseDeposits + (DayNumber * 625000.00) + (InstitutionWeight * 34000.00) + ((DayNumber % 6) * 820000.00) AS DECIMAL(18,2)) AS TotalDepositsLSL,
        CAST(BaseLoans + (DayNumber * 475000.00) + (InstitutionWeight * 27000.00) + ((DayNumber % 5) * 550000.00) AS DECIMAL(18,2)) AS TotalLoansLSL,
        CAST(BaseLiquidity + ((DayNumber % 10) * 0.0021) - (CASE WHEN InstitutionWeight IN (3, 6) THEN 0.0140 ELSE 0.0000 END) - (CASE WHEN DayNumber BETWEEN 33 AND 42 THEN 0.0180 ELSE 0.0000 END) AS DECIMAL(9,4)) AS LiquidityRatio,
        CAST(BaseCapital + ((DayNumber % 8) * 0.0014) - (CASE WHEN InstitutionWeight = 6 THEN 0.0110 ELSE 0.0000 END) AS DECIMAL(9,4)) AS CapitalAdequacyRatio,
        CAST(BaseNpl + ((DayNumber % 9) * 0.0018) + (CASE WHEN DayNumber BETWEEN 33 AND 42 THEN 0.0100 ELSE 0.0000 END) AS DECIMAL(9,4)) AS NplRatio,
        CAST(850 + (InstitutionWeight * 95) + (DayNumber * 8) + ((DayNumber % 6) * 35) AS INT) AS TransactionVolume,
        CAST((BaseDeposits * 0.028) + (DayNumber * 185000.00) + (InstitutionWeight * 75000.00) + ((DayNumber % 7) * 430000.00) AS DECIMAL(18,2)) AS TransactionValueLSL,
        CAST(0.0310 + ((DayNumber % 12) * 0.0016) - (BaseNpl * 0.0800) AS DECIMAL(9,4)) AS CreditGrowthRate,
        InflationRate,
        InterbankRate
    FROM Prepared
)
INSERT INTO m5.DailyFinancialIndicators (
    ObservationDate,
    InstitutionCode,
    InstitutionName,
    Region,
    InstitutionType,
    TotalDepositsLSL,
    TotalLoansLSL,
    LiquidityRatio,
    CapitalAdequacyRatio,
    NplRatio,
    TransactionVolume,
    TransactionValueLSL,
    CreditGrowthRate,
    InflationRate,
    InterbankRate,
    StressFlag
)
SELECT
    ObservationDate,
    InstitutionCode,
    InstitutionName,
    Region,
    InstitutionType,
    TotalDepositsLSL,
    TotalLoansLSL,
    LiquidityRatio,
    CapitalAdequacyRatio,
    NplRatio,
    TransactionVolume,
    TransactionValueLSL,
    CreditGrowthRate,
    InflationRate,
    InterbankRate,
    CASE
        WHEN LiquidityRatio < 0.2300
            OR CapitalAdequacyRatio < 0.1300
            OR NplRatio >= 0.0850
            OR CreditGrowthRate < 0.0280
        THEN 1
        ELSE 0
    END AS StressFlag
FROM Calculated
OPTION (MAXRECURSION 100);
GO

SELECT
    COUNT(*) AS ObservationRows,
    MIN(ObservationDate) AS FirstDate,
    MAX(ObservationDate) AS LastDate,
    SUM(CASE WHEN StressFlag = 1 THEN 1 ELSE 0 END) AS StressRows
FROM m5.DailyFinancialIndicators;
GO
