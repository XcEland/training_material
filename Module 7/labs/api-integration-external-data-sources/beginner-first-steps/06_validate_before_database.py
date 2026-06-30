"""
Step 6: Validate rows before database insertion.

External data should pass required-field and value-range checks before it is
loaded into SQL Server.
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd


OUTPUT_DIR = Path(__file__).resolve().parent / "outputs"


def validate_imf_rows(rows: list[dict[str, object]]) -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    accepted_rows: list[dict[str, object]] = []
    rejected_rows: list[dict[str, object]] = []

    for row in rows:
        errors: list[str] = []

        if not row.get("CountryCode"):
            errors.append("CountryCode is missing")
        if not row.get("CountryName"):
            errors.append("CountryName is missing")
        if not row.get("IndicatorCode"):
            errors.append("IndicatorCode is missing")
        if row.get("ObservationYear") is None:
            errors.append("ObservationYear is missing")
        if row.get("ObservationValue") is None:
            errors.append("ObservationValue is missing")

        value = row.get("ObservationValue")
        if value is not None and (float(value) < -100 or float(value) > 1000):
            errors.append("ObservationValue is outside the accepted range")

        if errors:
            rejected_rows.append({"row": row, "errors": errors})
        else:
            accepted_rows.append(row)

    return accepted_rows, rejected_rows


def main() -> None:
    sample_rows = [
        {
            "SourceName": "IMF DataMapper",
            "CountryCode": "ZAF",
            "CountryName": "South Africa",
            "IndicatorCode": "PCPIPCH",
            "IndicatorName": "Inflation",
            "ObservationYear": 2024,
            "ObservationValue": 4.7,
            "Unit": "Percent",
            "Frequency": "Annual",
        },
        {
            "SourceName": "IMF DataMapper",
            "CountryCode": "",
            "CountryName": "Bad Example",
            "IndicatorCode": "PCPIPCH",
            "IndicatorName": "Inflation",
            "ObservationYear": 2024,
            "ObservationValue": 9999,
            "Unit": "Percent",
            "Frequency": "Annual",
        },
    ]

    accepted, rejected = validate_imf_rows(sample_rows)

    OUTPUT_DIR.mkdir(exist_ok=True)
    pd.DataFrame(accepted).to_csv(OUTPUT_DIR / "06_accepted_rows.csv", index=False)
    pd.DataFrame(rejected).to_json(OUTPUT_DIR / "06_rejected_rows.json", orient="records", indent=2)

    print("Accepted rows:")
    print(pd.DataFrame(accepted))

    print("\nRejected rows:")
    for item in rejected:
        print(item)


if __name__ == "__main__":
    main()
