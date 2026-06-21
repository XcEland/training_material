from pathlib import Path

import numpy as np
import pandas as pd
from sqlalchemy import text

from connection_utils import get_sqlalchemy_engine


ENV_FILE = ".env"
OUTPUT_DIR = Path(__file__).with_name("outputs")

FX_RATES_TO_LSL = {
    "LSL": 1.0,
    "ZAR": 1.0,
    "USD": 18.25,
    "EUR": 19.75,
    "GBP": 23.10,
}


def extract_raw_transactions(engine):
    query = """
        SELECT
            RawTransactionID,
            TransactionReference,
            TransactionDateText,
            InstitutionCode,
            CounterpartyName,
            CurrencyCode,
            AmountText,
            TransactionType,
            Channel
        FROM m4.RawFinancialTransactions
        ORDER BY RawTransactionID;
    """
    return pd.read_sql(query, engine)


def transform_transactions(raw_df):
    df = raw_df.copy()
    extracted_rows = len(df)

    df["TransactionDate"] = pd.to_datetime(
        df["TransactionDateText"],
        format="mixed",
        errors="coerce",
        dayfirst=False,
    )
    df["CurrencyCode"] = df["CurrencyCode"].astype("string").str.strip().str.upper()
    df["Amount"] = pd.to_numeric(df["AmountText"], errors="coerce")
    df["InstitutionCode"] = df["InstitutionCode"].astype("string").str.strip().str.upper()
    df["CounterpartyName"] = df["CounterpartyName"].fillna("Unknown Counterparty")
    df["TransactionType"] = df["TransactionType"].fillna("Unclassified")
    df["Channel"] = df["Channel"].fillna("Unknown")

    required_columns = [
        "TransactionDate",
        "InstitutionCode",
        "CurrencyCode",
        "Amount",
        "TransactionType",
        "Channel",
    ]
    valid_mask = df[required_columns].notna().all(axis=1)
    valid_mask &= df["CurrencyCode"].isin(FX_RATES_TO_LSL.keys())
    valid_mask &= df["Amount"] >= 0

    clean_df = df.loc[valid_mask].copy()
    rejected_df = df.loc[~valid_mask].copy()

    clean_df["TransactionDate"] = clean_df["TransactionDate"].dt.date
    clean_df["FxRateToLSL"] = clean_df["CurrencyCode"].map(FX_RATES_TO_LSL)
    clean_df["AmountLSL"] = (clean_df["Amount"] * clean_df["FxRateToLSL"]).round(2)
    clean_df["AmountBand"] = pd.cut(
        clean_df["Amount"],
        bins=[-0.01, 10000, 50000, np.inf],
        labels=["Small", "Medium", "Large"],
    ).astype(str)

    output_columns = [
        "RawTransactionID",
        "TransactionReference",
        "TransactionDate",
        "InstitutionCode",
        "CounterpartyName",
        "CurrencyCode",
        "Amount",
        "AmountLSL",
        "TransactionType",
        "Channel",
        "AmountBand",
    ]

    clean_df = clean_df[output_columns]

    summary_df = (
        clean_df.groupby("CurrencyCode", as_index=False)
        .agg(
            TransactionCount=("TransactionReference", "count"),
            TotalAmount=("Amount", "sum"),
            TotalAmountLSL=("AmountLSL", "sum"),
            AverageAmount=("Amount", "mean"),
            StandardDeviationAmount=("Amount", "std"),
        )
        .fillna({"StandardDeviationAmount": 0})
    )

    numeric_columns = [
        "TotalAmount",
        "TotalAmountLSL",
        "AverageAmount",
        "StandardDeviationAmount",
    ]
    summary_df[numeric_columns] = summary_df[numeric_columns].round(2)

    metrics = {
        "extracted_rows": extracted_rows,
        "clean_rows": len(clean_df),
        "rejected_rows": len(rejected_df),
        "raw_amount_total": float(pd.to_numeric(df["AmountText"], errors="coerce").fillna(0).clip(lower=0).sum()),
        "clean_amount_total": float(np.round(clean_df["Amount"].to_numpy().sum(), 2)),
    }

    return clean_df, summary_df, rejected_df, metrics


def validate_results(clean_df, summary_df, metrics):
    if metrics["extracted_rows"] != metrics["clean_rows"] + metrics["rejected_rows"]:
        raise ValueError("Row-count reconciliation failed.")

    if clean_df[["RawTransactionID", "TransactionReference", "TransactionDate", "CurrencyCode", "Amount"]].isna().any().any():
        raise ValueError("Clean data still contains null values in required columns.")

    clean_amount_total = np.round(clean_df["Amount"].to_numpy().sum(), 2)
    summary_amount_total = np.round(summary_df["TotalAmount"].to_numpy().sum(), 2)

    if clean_amount_total != summary_amount_total:
        raise ValueError("NumPy total check failed between detail and summary data.")


def write_outputs(clean_df, summary_df):
    OUTPUT_DIR.mkdir(exist_ok=True)
    clean_df.to_csv(OUTPUT_DIR / "clean_transactions.csv", index=False)
    summary_df.to_csv(OUTPUT_DIR / "currency_summary.csv", index=False)
    clean_df.to_excel(OUTPUT_DIR / "clean_transactions.xlsx", index=False)


def load_to_sql(engine, clean_df, summary_df, metrics):
    with engine.begin() as conn:
        run_id = conn.execute(
            text("""
                INSERT INTO m4.EtlRunLog
                    (Status, ExtractedRows, CleanRows, RejectedRows, Message)
                OUTPUT inserted.RunID
                VALUES
                    ('Running', :extracted_rows, :clean_rows, :rejected_rows, 'ETL started');
            """),
            metrics,
        ).scalar_one()

        conn.execute(text("DELETE FROM m4.CleanFinancialTransactions;"))
        conn.execute(text("DELETE FROM m4.CurrencySummary;"))

        clean_df.to_sql(
            "CleanFinancialTransactions",
            con=conn,
            schema="m4",
            if_exists="append",
            index=False,
        )
        summary_df.to_sql(
            "CurrencySummary",
            con=conn,
            schema="m4",
            if_exists="append",
            index=False,
        )

        conn.execute(
            text("""
                UPDATE m4.EtlRunLog
                SET
                    CompletedAt = SYSUTCDATETIME(),
                    Status = 'Succeeded',
                    Message = 'ETL completed successfully'
                WHERE RunID = :run_id;
            """),
            {"run_id": run_id},
        )

    return run_id


def main():
    engine = get_sqlalchemy_engine(ENV_FILE)

    raw_df = extract_raw_transactions(engine)
    clean_df, summary_df, rejected_df, metrics = transform_transactions(raw_df)
    validate_results(clean_df, summary_df, metrics)
    write_outputs(clean_df, summary_df)
    run_id = load_to_sql(engine, clean_df, summary_df, metrics)

    print("ETL completed successfully.")
    print("Run ID:", run_id)
    print("Extracted rows:", metrics["extracted_rows"])
    print("Clean rows:", metrics["clean_rows"])
    print("Rejected rows:", metrics["rejected_rows"])
    print("\nCurrency summary:")
    print(summary_df)
    print("\nRejected rows for review:")
    print(rejected_df[["RawTransactionID", "TransactionReference", "TransactionDateText", "InstitutionCode", "CurrencyCode", "AmountText"]])


if __name__ == "__main__":
    main()
