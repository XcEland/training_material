"""
Secure sample for comparison with vulnerable_report_export.py.
"""

import os


def load_database_password() -> str | None:
    return os.environ.get("DB_PASSWORD")


def build_report_query() -> tuple[str, dict[str, str]]:
    sql = "SELECT * FROM m9.CustomerRiskProfile WHERE Country = :country"
    parameters = {"country": "Lesotho"}
    return sql, parameters
