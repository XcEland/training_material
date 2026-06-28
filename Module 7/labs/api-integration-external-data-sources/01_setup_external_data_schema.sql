-- ============================================================
-- MODULE 7 LAB
-- FILE 01: SETUP EXTERNAL DATA INTEGRATION SCHEMA
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm7')
BEGIN
    EXEC('CREATE SCHEMA m7');
END;
GO

IF OBJECT_ID('m7.ExternalDataQualityLog', 'U') IS NOT NULL DROP TABLE m7.ExternalDataQualityLog;
IF OBJECT_ID('m7.ImfWeoIndicators', 'U') IS NOT NULL DROP TABLE m7.ImfWeoIndicators;
IF OBJECT_ID('m7.BisPolicyRates', 'U') IS NOT NULL DROP TABLE m7.BisPolicyRates;
IF OBJECT_ID('m7.AuthorisedWebSources', 'U') IS NOT NULL DROP TABLE m7.AuthorisedWebSources;
IF OBJECT_ID('m7.ExternalRawPayloads', 'U') IS NOT NULL DROP TABLE m7.ExternalRawPayloads;
IF OBJECT_ID('m7.ExternalIntegrationRunLog', 'U') IS NOT NULL DROP TABLE m7.ExternalIntegrationRunLog;
GO

CREATE TABLE m7.ExternalIntegrationRunLog (
    RunID INT IDENTITY(1,1) PRIMARY KEY,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CompletedAt DATETIME2 NULL,
    SourceName VARCHAR(160) NOT NULL,
    Status VARCHAR(30) NOT NULL,
    AcceptedRows INT NOT NULL DEFAULT 0,
    RejectedRows INT NOT NULL DEFAULT 0,
    Message NVARCHAR(1000) NULL
);
GO

CREATE TABLE m7.ExternalRawPayloads (
    PayloadID INT IDENTITY(1,1) PRIMARY KEY,
    RunID INT NULL,
    SourceName VARCHAR(160) NOT NULL,
    PayloadFormat VARCHAR(20) NOT NULL,
    SourceUrl NVARCHAR(1000) NULL,
    PayloadText NVARCHAR(MAX) NOT NULL,
    RetrievedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (RunID) REFERENCES m7.ExternalIntegrationRunLog(RunID)
);
GO

CREATE TABLE m7.ImfWeoIndicators (
    ObservationID INT IDENTITY(1,1) PRIMARY KEY,
    SourceName VARCHAR(160) NOT NULL,
    CountryCode VARCHAR(10) NOT NULL,
    CountryName VARCHAR(120) NULL,
    IndicatorCode VARCHAR(60) NOT NULL,
    IndicatorName VARCHAR(250) NULL,
    ObservationYear INT NOT NULL,
    ObservationValue DECIMAL(18,6) NOT NULL,
    Unit VARCHAR(80) NULL,
    Frequency VARCHAR(30) NULL,
    QualityStatus VARCHAR(30) NOT NULL,
    LoadedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_m7_imf_weo_observation UNIQUE (SourceName, CountryCode, IndicatorCode, ObservationYear)
);
GO

CREATE TABLE m7.BisPolicyRates (
    PolicyRateID INT IDENTITY(1,1) PRIMARY KEY,
    SourceName VARCHAR(160) NOT NULL,
    Frequency CHAR(1) NOT NULL,
    ReferenceArea VARCHAR(10) NOT NULL,
    SeriesTitle NVARCHAR(300) NULL,
    ObservationDate DATE NOT NULL,
    PolicyRate DECIMAL(18,6) NOT NULL,
    ObservationStatus VARCHAR(20) NULL,
    QualityStatus VARCHAR(30) NOT NULL,
    LoadedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_m7_bis_policy_rate UNIQUE (SourceName, Frequency, ReferenceArea, ObservationDate)
);
GO

CREATE TABLE m7.AuthorisedWebSources (
    SourceID INT IDENTITY(1,1) PRIMARY KEY,
    SourceName VARCHAR(160) NOT NULL,
    ExternalSourceName VARCHAR(160) NOT NULL,
    SourceType VARCHAR(80) NOT NULL,
    OwnerName VARCHAR(160) NOT NULL,
    BaseUrl NVARCHAR(1000) NOT NULL,
    PermissionStatus VARCHAR(80) NOT NULL,
    QualityStatus VARCHAR(30) NOT NULL,
    LoadedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_m7_authorised_source UNIQUE (SourceName, ExternalSourceName)
);
GO

CREATE TABLE m7.ExternalDataQualityLog (
    QualityLogID INT IDENTITY(1,1) PRIMARY KEY,
    RunID INT NULL,
    SourceName VARCHAR(160) NOT NULL,
    RecordKey VARCHAR(250) NOT NULL,
    Severity VARCHAR(20) NOT NULL,
    RuleName VARCHAR(100) NOT NULL,
    Message NVARCHAR(1000) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (RunID) REFERENCES m7.ExternalIntegrationRunLog(RunID)
);
GO

SELECT 'm7 IMF/BIS external integration schema ready' AS StatusMessage;
GO
