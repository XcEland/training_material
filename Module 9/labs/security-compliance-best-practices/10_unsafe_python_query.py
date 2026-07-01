"""Unsafe SQL example for Module 9 security review."""


currency_code = input("Enter currency: ")

# Problem: raw input is inserted into SQL text.
query = f"SELECT CurrencyCode, RateDate, RateToLSL FROM m2.FxRates WHERE CurrencyCode = '{currency_code}'"

# The printed query shows why this is unsafe before anyone runs it on TrainingDB.
print(query)
