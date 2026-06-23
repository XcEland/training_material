import csv
import os
from pathlib import Path

import pyodbc

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None


if load_dotenv:
    load_dotenv()


CSV_FILE = Path(__file__).with_name("09_staging_transactions_sample.csv")


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

    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={username}", f"PWD={password}"])

    return pyodbc.connect(";".join(parts) + ";")


def read_csv_rows():
    # DictReader uses the CSV header row as column names.
    with CSV_FILE.open(newline="") as file:
        reader = csv.DictReader(file)
        return [
            (
                row["ReferenceCode"],
                row["AccountNumber"],
                row["TransactionDate"],
                row["ValueDate"],
                row["TransactionType"],
                row["Amount"],
                row["CurrencyCode"],
                row["Channel"],
                row["Status"],
            )
            for row in reader
        ]


def main():
    rows = read_csv_rows()
    reference_codes = [(row[0],) for row in rows]

    conn = get_connection()
    cursor = conn.cursor()

    cursor.fast_executemany = True

    # executemany() runs this DELETE once for each reference code in the list.
    # This removes only the sample CSV rows so rerunning the script does not create duplicates.
    cursor.executemany("""
        DELETE FROM m2.StagingTransactions
        WHERE ReferenceCode = ?;
    """, reference_codes)

    # executemany() runs this INSERT once for each CSV row.
    # With fast_executemany enabled, pyodbc sends the rows more efficiently.
    cursor.executemany("""
        INSERT INTO m2.StagingTransactions
            (ReferenceCode, AccountNumber, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status)
        VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?);
    """, rows)

    # commit() permanently saves the DELETE and INSERT changes in SQL Server.
    conn.commit()

    print(f"Loaded {len(rows)} CSV rows into m2.StagingTransactions.")

    # Verify the rows loaded from the CSV file.
    cursor.execute("""
        SELECT
            ReferenceCode,
            AccountNumber,
            TransactionDate,
            Amount,
            CurrencyCode,
            Status
        FROM m2.StagingTransactions
        WHERE ReferenceCode LIKE 'M2-CSV-%'
        ORDER BY ReferenceCode;
    """)

    for row in cursor.fetchall():
        print(row)

    cursor.close()  # Close the SQL command object after we are done with it.
    conn.close()    # Close the database connection.


if __name__ == "__main__":
    main()
