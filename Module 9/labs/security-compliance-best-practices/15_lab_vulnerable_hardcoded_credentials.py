"""Vulnerable lab sample: credentials are hardcoded in source code."""

password = "AdminPassword123"

# This example intentionally breaks the Module 9 credential rule.
connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=localhost,1433;"
    "DATABASE=TrainingDB;"
    "UID=admin_user;"
    f"PWD={password};"
)

print(connection_string)
