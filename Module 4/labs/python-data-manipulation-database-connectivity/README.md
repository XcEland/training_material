# Python Data Manipulation and Database Connectivity

This Module 4 lab uses Jupyter notebooks as the main delivery format. Students extract SQL Server data into Python, clean and transform it with pandas, validate the results with NumPy, write CSV/Excel outputs, and load prepared results back to SQL Server.

The notebooks also run without SQL Server by falling back to the included CSV sample data. This makes the exercises usable in a local virtual environment, VS Code, JupyterLab, or Google Colab.

## Learning Order

1. Run the SQL setup script if SQL Server is available.
2. Open the database connectivity notebook and test `pyodbc`, SQLAlchemy, and pandas extraction.
3. Work through `05_pandas_weo_transformation_basics.ipynb` for pandas basics using the IMF WEO Excel dataset.
4. Work through `06_numpy_weo_array_validation_basics.ipynb` to understand NumPy arrays, shape, axis direction, changes, missing values, and outlier checks.
5. Clean and transform transaction data with pandas in the existing workflow notebook.
6. Validate totals, outliers, and row quality with NumPy in the existing transaction validation notebook.
7. Export CSV/Excel files and load cleaned results back to SQL Server when a connection is available.

New examples and datasets must be added without deleting existing labs. The WEO dataset is now the first pandas and NumPy teaching dataset, while the existing transaction dataset remains available for ETL and validation practice.

## Files

```text
Module 4/labs/python-data-manipulation-database-connectivity/
├── README.md
├── .env
├── .env.windows
├── 01_setup_python_etl_dataset.sql
├── 01_database_connectivity_pyodbc_sqlalchemy_pandas.ipynb
├── 02_pandas_cleaning_transformation_workflow.ipynb
├── 03_numpy_quantitative_validation.ipynb
├── 04_file_io_etl_load_back_to_sql.ipynb
├── 05_pandas_weo_transformation_basics.ipynb
├── 06_numpy_weo_array_validation_basics.ipynb
├── data/
│   ├── WEOApr2026all.xlsx
│   └── m4_raw_financial_transactions_sample.csv
├── outputs/
├── etl_peer_review_checklist.md
├── etl_design_execution_log.md
├── demo_01_pyodbc_connection.py
├── demo_02_pandas_sqlalchemy_extract.py
├── lab_etl_pipeline.py
└── lab_etl_pipeline_windows.py
```

The `.py` files are kept as optional script references. The notebooks are the main lab path.

## pyodbc vs SQLAlchemy: Connection Strategy Comparison

| Strategy | Best use | Typical object | Role in this lab |
| --- | --- | --- | --- |
| `pyodbc` direct connection | Driver and credential tests, stored procedure calls, cursor work | `pyodbc.Connection`, `cursor` | Prove SQL Server is reachable before extracting data |
| SQLAlchemy engine | Reusable ETL connections and pandas integration | `sqlalchemy.Engine` | Main connection strategy for `pd.read_sql` and `df.to_sql` |
| pandas with SQLAlchemy | DataFrame extraction/loading | `pd.read_sql`, `DataFrame.to_sql` | Move data between SQL Server and Python analytical workflows |

Use `pyodbc` for direct connection checks. Use SQLAlchemy with pandas for the main ETL flow.

## Notebook Coverage

| Notebook | Focus |
| --- | --- |
| `01_database_connectivity_pyodbc_sqlalchemy_pandas.ipynb` | Environment setup, SQL Server connection strings, `pyodbc`, SQLAlchemy, and pandas extraction |
| `05_pandas_weo_transformation_basics.ipynb` | Beginner-friendly pandas basics and transformations using the IMF WEO Excel dataset |
| `06_numpy_weo_array_validation_basics.ipynb` | Beginner-friendly NumPy arrays, axis direction, year-on-year changes, missing values, and outlier checks using the IMF WEO Excel dataset |
| `02_pandas_cleaning_transformation_workflow.ipynb` | DataFrame inspection, missing values, type conversion, normalization, grouping, pivoting, and a public World Bank API enrichment example |
| `03_numpy_quantitative_validation.ipynb` | NumPy arrays, descriptive statistics, z-scores, outlier flags, and reconciliation checks |
| `04_file_io_etl_load_back_to_sql.ipynb` | File I/O, CSV/Excel exports, transformation functions, validation rules, and optional SQL Server load-back |

## Required Validation Gate Before SQL Load

Before any DataFrame is loaded back to SQL Server, apply and log these checks:

1. Check for null values in target non-nullable columns with `df.isnull().sum()`.
2. Verify DataFrame types against the target table schema with `df.dtypes`.
3. Confirm row counts match the expected extraction count.

The final notebook prints all three checks before writing files or loading SQL Server tables.

## Dataset Notes

The lab uses:

- IMF WEO Excel workbook `data/WEOApr2026all.xlsx` for the beginner pandas and NumPy transformation labs.
- SQL Server table `m4.RawFinancialTransactions` when the setup script has been run.
- Local fallback file `data/m4_raw_financial_transactions_sample.csv`.
- Built-in fallback rows inside each notebook if the notebook is moved without the CSV file.
- World Bank Indicators API enrichment in the pandas notebook for a real public-data example. The API supports JSON output with `format=json` and paging with `per_page`.

World Bank API reference: <https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures>

## Local Setup

From the repository root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
pip install notebook jupyterlab openpyxl requests
```

If SQL Server is available, create the Module 4 tables and sample data:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 4/labs/python-data-manipulation-database-connectivity/01_setup_python_etl_dataset.sql"
```

Start Jupyter:

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 4/labs/python-data-manipulation-database-connectivity"
jupyter lab
```

You can also use:

```bash
python -m notebook
```

## Windows Setup

Use `.env.windows`. If using SQL Server Express, change:

```env
DB_SERVER=localhost\SQLEXPRESS
```

From PowerShell:

```powershell
cd "$HOME\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt
pip install notebook jupyterlab openpyxl requests

sqlcmd -S localhost -E -C -i "Module 4\labs\python-data-manipulation-database-connectivity\01_setup_python_etl_dataset.sql"
```

Then open the lab folder in JupyterLab or VS Code and run the notebooks in order.

## Google Colab Setup

1. Upload a notebook to Colab.
2. Run the first install/import cell.
3. Upload `data/WEOApr2026all.xlsx` when running the WEO pandas or NumPy basics notebooks.
4. Upload `data/m4_raw_financial_transactions_sample.csv` if you want the full transaction sample dataset.
5. If the files are not uploaded, the notebooks still run with small built-in fallback datasets.
6. SQL Server connection cells will skip safely unless your SQL Server is reachable from Colab.

## Expected Outputs

The final notebook writes:

```text
outputs/clean_transactions_notebook.csv
outputs/clean_transactions_notebook.xlsx
outputs/currency_summary_notebook.csv
```

When SQL Server is connected, it also loads:

```text
m4.CleanFinancialTransactions
m4.CurrencySummary
m4.EtlRunLog
```

## SQL Quick Check

```sql
SELECT COUNT(*) AS CleanRows FROM m4.CleanFinancialTransactions;
SELECT * FROM m4.CurrencySummary ORDER BY CurrencyCode;
SELECT TOP 5 * FROM m4.EtlRunLog ORDER BY RunID DESC;
```

## Review Checklist

Use `etl_peer_review_checklist.md` to review notebook work for:

- connection handling
- row-count reconciliation
- null handling
- currency normalization
- NumPy validation
- file export checks
- SQL Server load verification

Use `etl_design_execution_log.md` as the Day 4 evidence artefact. Complete the design sections before coding, then complete the execution sections after running the notebook. This log is referenced again in the Day 10 Capstone.
