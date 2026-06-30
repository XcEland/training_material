"""
Step 7: Load accepted rows into SQL Server with pyodbc.

Connection settings are read from the Module 7 .env file. This keeps passwords
out of the Python script.
"""

from __future__ import annotations

import os
from pathlib import Path

import pyodbc
from dotenv import load_dotenv


LAB_DIR = Path(__file__).resolve().parents[1]
ENV_PATH = LAB_DIR / ".env"


def connect_to_sql_server() -> pyodbc.Connection:
    if not ENV_PATH.exists():
        raise FileNotFoundError(f"Module 7 .env file not found: {ENV_PATH}")

    load_dotenv(ENV_PATH)

    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("DB_SERVER", "localhost,1433")
    database = os.getenv("DB_NAME", "TrainingDB")
    username = os.getenv("DB_USER", "sa")
    password = os.getenv("DB_PASSWORD", "")
    trusted = os.getenv("DB_TRUSTED", "no").lower() in ("yes", "true", "1")

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        "Encrypt=yes",
        "TrustServerCertificate=yes",
        "Connection Timeout=5",
    ]
    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={username}", f"PWD={password}"])

    print(f"Using environment file: {ENV_PATH}")
    print(f"Connecting to SQL Server: server={server}, database={database}, driver={driver}")
    return pyodbc.connect(";".join(parts) + ";")


def create_table_if_not_exists(cursor: pyodbc.Cursor) -> None:
    sql = """
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm7')
    BEGIN
        EXEC('CREATE SCHEMA m7');
    END;

    IF OBJECT_ID('m7.ExternalImfInflationBeginner', 'U') IS NULL
    BEGIN
        CREATE TABLE m7.ExternalImfInflationBeginner (
            Id INT IDENTITY(1,1) PRIMARY KEY,
            SourceName NVARCHAR(100),
            CountryCode NVARCHAR(20),
            CountryName NVARCHAR(100),
            IndicatorCode NVARCHAR(50),
            IndicatorName NVARCHAR(200),
            ObservationYear INT,
            ObservationValue FLOAT,
            Unit NVARCHAR(100),
            Frequency NVARCHAR(50),
            LoadedAt DATETIME2 DEFAULT SYSUTCDATETIME()
        );
    END;
    """
    cursor.execute(sql)


def insert_imf_rows(cursor: pyodbc.Cursor, rows: list[dict[str, object]]) -> None:
    sql = """
    INSERT INTO m7.ExternalImfInflationBeginner (
        SourceName,
        CountryCode,
        CountryName,
        IndicatorCode,
        IndicatorName,
        ObservationYear,
        ObservationValue,
        Unit,
        Frequency
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
    """

    for row in rows:
        cursor.execute(
            sql,
            row["SourceName"],
            row["CountryCode"],
            row["CountryName"],
            row["IndicatorCode"],
            row["IndicatorName"],
            row["ObservationYear"],
            row["ObservationValue"],
            row["Unit"],
            row["Frequency"],
        )


def main() -> None:
    sample_accepted_rows = [
        {
            "SourceName": "IMF DataMapper",
            "CountryCode": "ZAF",
            "CountryName": "South Africa",
            "IndicatorCode": "PCPIPCH",
            "IndicatorName": "Inflation, average consumer prices",
            "ObservationYear": 2024,
            "ObservationValue": 4.7,
            "Unit": "Percent change",
            "Frequency": "Annual",
        }
    ]

    try:
        connection = connect_to_sql_server()
        cursor = connection.cursor()
        create_table_if_not_exists(cursor)
        insert_imf_rows(cursor, sample_accepted_rows)
        connection.commit()
        cursor.close()
        connection.close()
    except pyodbc.Error as exc:
        print("\nSQL Server connection failed.")
        print("Check these items:")
        print("- SQL Server is running")
        print("- DB_SERVER in Module 7 .env is correct")
        print("- The ODBC driver in DB_DRIVER is installed")
        print("- The username/password in .env are valid")
        print(f"\nODBC error: {exc}")
        raise SystemExit(1)

    print("Data loaded successfully into m7.ExternalImfInflationBeginner.")


if __name__ == "__main__":
    main()
