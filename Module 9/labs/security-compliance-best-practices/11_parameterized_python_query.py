"""Safe SQL example using validation and query parameters."""

from sqlalchemy import text


# Match the currencies loaded into m2.FxRates in Module 2.
allowed_currencies = {"USD", "EUR", "ZAR", "GBP"}
currency_code = input("Currency code: ").strip().upper()

if currency_code not in allowed_currencies:
    raise ValueError("Invalid currency code supplied")

# The SQL text is fixed. The currency value is passed separately in params.
query = text("""
SELECT CurrencyCode, RateDate, RateToLSL
FROM m2.FxRates
WHERE CurrencyCode = :currency_code
""")

params = {"currency_code": currency_code}

print(query)
print(params)

# In the connected lab, use:
# df = pd.read_sql(query, engine, params=params)
