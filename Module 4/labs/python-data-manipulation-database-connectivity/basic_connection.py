import pandas as pd
import pyodbc
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# --------------------------------------------------
# 1. Database connection details
# --------------------------------------------------

server = "localhost"
database = "FinancialDB"
username = "sa"
password = "YourPassword"

# --------------------------------------------------
# 2. Create pyodbc connection
# --------------------------------------------------

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
)

print("Connected using pyodbc")

# --------------------------------------------------
# 3. Extract data from SQL Server into pandas
# --------------------------------------------------

query = """
SELECT 
    country,
    indicator,
    year,
    value
FROM weo_data
"""

df = pd.read_sql(query, conn)

print("Data extracted successfully")
print(df.head())

# --------------------------------------------------
# 4. Inspect the data
# --------------------------------------------------

print(df.info())
print(df.isnull().sum())

# --------------------------------------------------
# 5. Clean column names
# --------------------------------------------------

df.columns = df.columns.str.strip().str.lower()

# --------------------------------------------------
# 6. Convert data types
# --------------------------------------------------

df["year"] = pd.to_numeric(df["year"], errors="coerce")
df["value"] = pd.to_numeric(df["value"], errors="coerce")

# --------------------------------------------------
# 7. Handle missing values
# --------------------------------------------------

df = df.dropna(subset=["year", "value"])

# --------------------------------------------------
# 8. Remove duplicate records
# --------------------------------------------------

df = df.drop_duplicates()

# --------------------------------------------------
# 9. Create new analytical columns
# --------------------------------------------------

df["value_category"] = df["value"].apply(
    lambda x: "High" if x > 20 else "Normal"
)

# --------------------------------------------------
# 10. Create SQLAlchemy engine for saving data
# --------------------------------------------------

connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
)

encoded_conn_str = quote_plus(connection_string)

engine = create_engine(
    f"mssql+pyodbc:///?odbc_connect={encoded_conn_str}"
)

# --------------------------------------------------
# 11. Load cleaned data back into SQL Server
# --------------------------------------------------

df.to_sql(
    name="cleaned_weo_data",
    con=engine,
    if_exists="replace",
    index=False
)

print("Cleaned data loaded back into SQL Server")