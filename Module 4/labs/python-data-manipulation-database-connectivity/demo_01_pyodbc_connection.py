import argparse

from connection_utils import get_pyodbc_connection, load_settings


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--env", default=".env")
    args = parser.parse_args()

    settings = load_settings(args.env)
    print("Connecting to:", settings["server"])
    print("Database:", settings["database"])
    print("Driver:", settings["driver"])

    with get_pyodbc_connection(args.env) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM m4.RawFinancialTransactions;")
        raw_rows = cursor.fetchone()[0]

        cursor.execute("SELECT TOP 5 TransactionReference, CurrencyCode, AmountText FROM m4.RawFinancialTransactions ORDER BY RawTransactionID;")
        rows = cursor.fetchall()

    print("pyodbc connected successfully.")
    print("Raw rows:", raw_rows)
    print("\nSample rows:")
    for row in rows:
        print(row.TransactionReference, row.CurrencyCode, row.AmountText)


if __name__ == "__main__":
    main()
