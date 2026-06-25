import pandas as pd

# 1. Load dataset
df = pd.read_excel("weo_data.xlsx")

# 2. Inspect data
print(df.head())
print(df.info())
print(df.columns)

# 3. Clean column names
df.columns = df.columns.astype(str).str.strip().str.lower().str.replace(" ", "_")

# 4. Rename important columns
df.rename(columns={
    "country": "country",
    "subject_descriptor": "indicator"
}, inplace=True)

# 5. Select year columns
year_cols = ["2018", "2019", "2020", "2021", "2022"]

# 6. Convert year columns to numeric
df[year_cols] = df[year_cols].apply(pd.to_numeric, errors="coerce")

# 7. Fill missing values using mean
df[year_cols] = df[year_cols].fillna(df[year_cols].mean())

# 8. Remove duplicates
df.drop_duplicates(inplace=True)

# 9. Reshape from wide to long
long_df = df.melt(
    id_vars=["country", "indicator"],
    value_vars=year_cols,
    var_name="year",
    value_name="value"
)

# 10. Convert year to integer
long_df["year"] = long_df["year"].astype(int)

# 11. Create analytical column
long_df["value_category"] = pd.cut(
    long_df["value"],
    bins=[-float("inf"), 5, 15, float("inf")],
    labels=["Low", "Moderate", "High"]
)

# 12. Export cleaned data
long_df.to_csv("analysis_ready_weo_data.csv", index=False)