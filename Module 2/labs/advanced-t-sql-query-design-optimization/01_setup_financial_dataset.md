-- ============================================================
-- MODULE 2 LAB
-- FILE 01: SETUP FINANCIAL TRANSACTIONS DATASET - SCHEMA CONTEXT
-- ============================================================

-- Database
-- TrainingDB

-- Schema
-- m2

-- Table: m2.Counterparties
-- CounterpartyID INT IDENTITY PRIMARY KEY
-- CounterpartyName VARCHAR(120)
-- Sector VARCHAR(50)
-- Country VARCHAR(50)
-- RiskRating VARCHAR(20)

-- Table: m2.Accounts
-- AccountID INT IDENTITY PRIMARY KEY
-- AccountNumber VARCHAR(30)
-- CounterpartyID INT FOREIGN KEY to m2.Counterparties
-- AccountType VARCHAR(40)
-- CurrencyCode CHAR(3)
-- CurrentBalance DECIMAL(18,2)
-- OpenedDate DATE
-- AccountStatus VARCHAR(20)

-- Table: m2.FxRates
-- CurrencyCode CHAR(3)
-- RateDate DATE
-- RateToLSL DECIMAL(18,6)
-- Primary key: CurrencyCode, RateDate

-- Table: m2.FinancialTransactions
-- TransactionID BIGINT IDENTITY PRIMARY KEY
-- AccountID INT FOREIGN KEY to m2.Accounts
-- TransactionDate DATE
-- ValueDate DATE
-- TransactionType VARCHAR(30)
-- Amount DECIMAL(18,2)
-- CurrencyCode CHAR(3)
-- Channel VARCHAR(30)
-- Status VARCHAR(20)
-- ReferenceCode VARCHAR(40)
-- CreatedAt DATETIME2

-- Table: m2.StagingTransactions
-- ReferenceCode VARCHAR(40) PRIMARY KEY
-- AccountNumber VARCHAR(30)
-- TransactionDate DATE
-- ValueDate DATE
-- TransactionType VARCHAR(30)
-- Amount DECIMAL(18,2)
-- CurrencyCode CHAR(3)
-- Channel VARCHAR(30)
-- Status VARCHAR(20)

-- Table: m2.ErrorLog
-- ErrorLogID INT IDENTITY PRIMARY KEY
-- ErrorTime DATETIME2
-- ProcedureName VARCHAR(100)
-- ErrorNumber INT
-- ErrorMessage NVARCHAR(4000)

-- Table: m2.TransactionAudit
-- AuditID BIGINT IDENTITY PRIMARY KEY
-- TransactionID BIGINT
-- ActionName VARCHAR(30)
-- OldStatus VARCHAR(20)
-- NewStatus VARCHAR(20)
-- OldAmount DECIMAL(18,2)
-- NewAmount DECIMAL(18,2)
-- ChangedBy SYSNAME
-- ChangedAt DATETIME2

-- Table: m2.MonthlyTransactionSummary
-- SummaryMonth DATE
-- CurrencyCode CHAR(3)
-- PostedTransactionCount INT
-- PostedAmount DECIMAL(18,2)
-- LoadedAt DATETIME2
-- Primary key: SummaryMonth, CurrencyCode

-- Table: m2.OptimizationBenchmark
-- BenchmarkID INT IDENTITY PRIMARY KEY
-- QueryName VARCHAR(100)
-- QueryVersion VARCHAR(30)
-- RowsReturned INT
-- ElapsedMs INT
-- Notes VARCHAR(300)
-- CapturedAt DATETIME2

-- Dataset notes
-- Counterparties include banks, custodians, payment systems, treasury units, and remittance entities.
-- Accounts are linked to counterparties through CounterpartyID.
-- FxRates contains daily exchange rates from 2026-01-01 to 2026-06-30.
-- FinancialTransactions contains 30000 generated transactions across 15 accounts.
-- StagingTransactions contains rows used by the MERGE lab.
-- MonthlyTransactionSummary is created by the bulk-style INSERT SELECT lab.
-- OptimizationBenchmark is created by the query optimization benchmark lab.

-- Preview checks after setup
SELECT TOP 5 * FROM m2.Counterparties;
SELECT TOP 5 * FROM m2.Accounts;
SELECT TOP 5 * FROM m2.FxRates;
SELECT TOP 5 * FROM m2.FinancialTransactions;
SELECT TOP 5 * FROM m2.StagingTransactions;
