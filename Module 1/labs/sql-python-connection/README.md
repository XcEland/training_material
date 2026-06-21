# Python SQL Server Connection

This lab connects Python to SQL Server and prints the top 5 records from `TrainingDB.dbo.Customers`.

## Linux Setup

From the project root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r Setup/requirements.txt
```

Make sure the database exists and has data:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/01_ddl_create_database_and_tables.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/02_dml_insert_records.sql"
```

## Environment Variables

The script reads these values from:

```text
Module 1/labs/sql-python-connection/.env
```

```env
DB_SERVER=localhost,1433
DB_NAME=TrainingDB
DB_USER=sa
DB_PASSWORD=StrongPassw0rd!2026
DB_DRIVER=ODBC Driver 18 for SQL Server
```

## Run on Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 1/labs/sql-python-connection"
python3 test_sql_connection.py
```

On this Linux setup, use `python3`. If `python` is not installed as an alias, `python test_sql_connection.py` will fail with `Command 'python' not found`.

## Run on Windows

Use `.env.windows`:

```env
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_SERVER=localhost
DB_NAME=TrainingDB
DB_AUTH=windows
DB_TRUSTED=yes
DB_TRUST_CERT=yes
```

If you use SQL Server Express, change `DB_SERVER` to:

```env
DB_SERVER=localhost\SQLEXPRESS
```

Create and populate the database from PowerShell:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
sqlcmd -S localhost -E -C -i "Module 1\labs\sql-fundamentals\01_ddl_create_database_and_tables.sql"
sqlcmd -S localhost -E -C -i "Module 1\labs\sql-fundamentals\02_dml_insert_records.sql"
```

From PowerShell:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install -r Setup\requirements.txt
cd "$env:USERPROFILE\Desktop\Trainingcred Institute\Module 1\labs\sql-python-connection"
python test_sql_connection_windows.py
```

Expected output includes:

```text
Python connected successfully!

Top 5 customer records:
id   name                 country      score
---------------------------------------------
1    Maria                Germany        350
2    John                 USA            900
3    Georg                UK             750
4    Martin               Germany        500
5    Peter                USA              0
```

## Quick Checks

```bash
docker ps
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -Q "SELECT TOP 5 id, name, country, score FROM dbo.Customers ORDER BY id;"
```

If Python says `No module named 'pyodbc'`, activate the virtual environment first:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
```

Then run the Linux script with:

```bash
python3 "Module 1/labs/sql-python-connection/test_sql_connection.py"
```
