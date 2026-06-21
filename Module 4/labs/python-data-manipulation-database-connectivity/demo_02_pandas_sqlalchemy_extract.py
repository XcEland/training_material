import argparse

import pandas as pd

from connection_utils import get_sqlalchemy_engine, load_settings


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--env", default=".env")
    args = parser.parse_args()

    settings = load_settings(args.env)
    print("Extracting with pandas + SQLAlchemy from:", settings["server"])

    engine = get_sqlalchemy_engine(args.env)
    query = """
        SELECT
            RawTransactionID,
            TransactionReference,
            TransactionDateText,
            InstitutionCode,
            CurrencyCode,
            AmountText,
            TransactionType,
            Channel
        FROM m4.RawFinancialTransactions
        ORDER BY RawTransactionID;
    """

    df = pd.read_sql(query, engine)
    print("Rows extracted:", len(df))
    print("\nDataFrame info:")
    print(df.info())
    print("\nFirst five rows:")
    print(df.head())


if __name__ == "__main__":
    main()
