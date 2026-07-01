"""Mask sensitive values before reports are distributed."""

import pandas as pd


def mask_value(value):
    if pd.isna(value):
        return None

    value = str(value).strip()

    if len(value) <= 2:
        return "*" * len(value)

    return value[0] + "*" * (len(value) - 2) + value[-1]


df = pd.DataFrame(
    {
        "TransactionID": [1, 2],
        "CounterpartyName": ["Maseru Commercial Bank", "CB"],
        "Amount": [1500.00, 780.50],
    }
)

# Keep the reporting value, then remove the raw sensitive value.
df["CounterpartyMasked"] = df["CounterpartyName"].apply(mask_value)
df = df.drop(columns=["CounterpartyName"])

print(df)
