# Module 1: Foundations, SQL Fundamentals, and Python Connection

Module 1 sets up the course foundation: basic Python, SQL fundamentals, and a live Python-to-SQL Server connection.

## Labs

```text
Module 1/labs/
├── python-fundamentals/
├── sql-fundamentals/
└── sql-python-connection/
```

## What To Run First

Start with SQL fundamentals:

```bash
cd "$HOME/Desktop/IRES"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/01_ddl_create_database_and_tables.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/02_dml_insert_records.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/03_dql_select_queries.sql"
```

Then test Python connectivity:

```bash
cd "$HOME/Desktop/IRES"
source .venv/bin/activate
python "Module 1/labs/sql-python-connection/test_sql_connection.py"
```

## Windows Notes

For Windows learners, use the Windows-specific Python connection script:

```powershell
cd "$HOME\Desktop\IRES\Module 1\labs\sql-python-connection"
python test_sql_connection_windows.py
```

See the individual lab README files for full Linux and Windows commands.
