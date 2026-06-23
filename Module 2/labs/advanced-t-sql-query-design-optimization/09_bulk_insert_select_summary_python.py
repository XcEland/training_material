import os
from collections import defaultdict
from datetime import date
from decimal import Decimal

import pyodbc

# python-dotenv is optional. If installed, it lets this script read a local .env file.
try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None


# Load .env values when python-dotenv is available.
if load_dotenv:
    load_dotenv()


def get_connection():
    # Read database connection settings from environment variables.
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("DB_SERVER", "localhost")
    database = os.getenv("DB_NAME", "TrainingDB")
    username = os.getenv("DB_USER") or os.getenv("DB_USERNAME")
    password = os.getenv("DB_PASSWORD")
    trusted = os.getenv("DB_TRUSTED", "no").lower() in ("yes", "true", "1")

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        "Encrypt=yes",
        "TrustServerCertificate=yes",
    ]

    # Use Windows authentication when DB_TRUSTED=yes. Otherwise use username/password.
    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={username}", f"PWD={password}"])

    return pyodbc.connect(";".join(parts) + ";")


def month_start(transaction_date):
    # Convert any date in a month to the first day of that month.
    # Example: 2026-06-14 becomes 2026-06-01.
    return date(transaction_date.year, transaction_date.month, 1)


def main():
    conn = get_connection()
    cursor = conn.cursor()

    # Create the destination summary table if the SQL setup script has not created it yet.
    cursor.execute("""
        IF OBJECT_ID('m2.MonthlyTransactionSummary', 'U') IS NULL
        BEGIN
            CREATE TABLE m2.MonthlyTransactionSummary (
                SummaryMonth DATE NOT NULL,
                CurrencyCode CHAR(3) NOT NULL,
                PostedTransactionCount INT NOT NULL,
                PostedAmount DECIMAL(18,2) NOT NULL,
                LoadedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
                CONSTRAINT PK_M2_MonthlyTransactionSummary
                    PRIMARY KEY (SummaryMonth, CurrencyCode)
            );
        END;
    """)

    # Extract the rows that will be summarized.
    cursor.execute("""
        SELECT
            TransactionDate,
            CurrencyCode,
            Amount
        FROM m2.FinancialTransactions
        WHERE Status = 'Posted';
    """)

    # monthly_totals stores one summary row per (month, currency) pair.
    monthly_totals = defaultdict(lambda: {"count": 0, "amount": Decimal("0.00")})

    # Group and total the SQL rows in Python.
    for transaction_date, currency_code, amount in cursor.fetchall():
        key = (month_start(transaction_date), currency_code)
        monthly_totals[key]["count"] += 1
        monthly_totals[key]["amount"] += amount

    # Convert the dictionary into rows that match m2.MonthlyTransactionSummary.
    rows_to_insert = [
        (summary_month, currency_code, values["count"], values["amount"])
        for (summary_month, currency_code), values in monthly_totals.items()
    ]

    # Clear old lab output so the script can be rerun.
    cursor.execute("TRUNCATE TABLE m2.MonthlyTransactionSummary;")

    cursor.fast_executemany = True

    # executemany() runs this INSERT once for each summary row.
    # With fast_executemany enabled, pyodbc sends the rows more efficiently.
    cursor.executemany("""
        INSERT INTO m2.MonthlyTransactionSummary
            (SummaryMonth, CurrencyCode, PostedTransactionCount, PostedAmount)
        VALUES (?, ?, ?, ?);
    """, rows_to_insert)

    # commit() permanently saves the inserted summary rows in SQL Server.
    conn.commit()

    print(f"Loaded {len(rows_to_insert)} monthly summary rows.")

    # Read the loaded rows back for a quick verification.
    cursor.execute("""
        SELECT
            SummaryMonth,
            CurrencyCode,
            PostedTransactionCount,
            PostedAmount
        FROM m2.MonthlyTransactionSummary
        ORDER BY SummaryMonth, CurrencyCode;
    """)

    for row in cursor.fetchall():
        print(row)

    cursor.close()  # Close the SQL command object after we are done with it.
    conn.close()    # Close the database connection.


# This runs main() only when the file is executed directly.
if __name__ == "__main__":
    main()
