"""
Intentionally vulnerable sample for Module 9 scanner practice.

Do not copy this pattern into production code.
"""

password = "PlainTextTrainingPassword"


def build_report_query(country: str) -> str:
    # Problem: user input is inserted directly into SQL text.
    return f"SELECT * FROM m9.CustomerRiskProfile WHERE Country = '{country}'"
