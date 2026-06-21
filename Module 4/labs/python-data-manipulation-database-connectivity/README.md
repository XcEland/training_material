# Python Data Manipulation and Database Connectivity

This Module 4 lab builds a Python ETL pipeline that extracts SQL Server data, cleans and transforms it with pandas, validates it with NumPy, writes CSV/Excel outputs, and loads results back to SQL Server.

Guiding documents:

- `Transact-SQL training_program.pdf`
- `Transact-SQL  workbook.pdf`
- `Setup/requirements.txt`

## Learning Order

1. Prepare raw financial transaction data with quality issues.
2. Connect with `pyodbc` and SQLAlchemy.
3. Extract SQL Server data into pandas.
4. Clean and transform the DataFrame.
5. Validate row counts and numeric totals with NumPy.
6. Export CSV/Excel files.
7. Load cleaned summaries back to SQL Server.

## Files

```text
Module 4/labs/python-data-manipulation-database-connectivity/
├── README.md
├── .env
├── .env.windows
├── 01_setup_python_etl_dataset.sql
├── demo_01_pyodbc_connection.py
├── demo_02_pandas_sqlalchemy_extract.py
├── lab_etl_pipeline.py
├── lab_etl_pipeline_windows.py
├── etl_peer_review_checklist.md
└── outputs/
```

## Linux Setup

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 4/labs/python-data-manipulation-database-connectivity/01_setup_python_etl_dataset.sql"
```

Run demos and lab:

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 4/labs/python-data-manipulation-database-connectivity"

python demo_01_pyodbc_connection.py
python demo_02_pandas_sqlalchemy_extract.py
python lab_etl_pipeline.py
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

sqlcmd -S localhost -E -C -i "Module 4\labs\python-data-manipulation-database-connectivity\01_setup_python_etl_dataset.sql"
```

Run:

```powershell
cd "$HOME\Desktop\Trainingcred Institute\Module 4\labs\python-data-manipulation-database-connectivity"

python demo_01_pyodbc_connection.py --env .env.windows
python demo_02_pandas_sqlalchemy_extract.py --env .env.windows
python lab_etl_pipeline_windows.py
```

## Expected Outputs

The ETL script writes:

```text
outputs/clean_transactions.csv
outputs/clean_transactions.xlsx
outputs/currency_summary.csv
```

It also loads results into:

```text
m4.CleanFinancialTransactions
m4.CurrencySummary
m4.EtlRunLog
```

## Quick Check

```sql
SELECT COUNT(*) AS CleanRows FROM m4.CleanFinancialTransactions;
SELECT * FROM m4.CurrencySummary ORDER BY CurrencyCode;
SELECT TOP 5 * FROM m4.EtlRunLog ORDER BY RunID DESC;
```

## Review Checklist

Use `etl_peer_review_checklist.md` to review ETL scripts for:

- connection handling
- row-count reconciliation
- null handling
- currency normalisation
- NumPy validation
- SQL Server load verification
