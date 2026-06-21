# SQL Fundamentals: DDL, DML and DQL

This lab introduces core SQL concepts using SQL Server 2022 running in Docker on Linux. You will create a small training database, insert sample customer and banking-style records, query them with `SELECT`, and practice safe `UPDATE`, `DELETE`, and optional `ALTER` statements.

The exercise is guided by these course documents:

- `Docs/02_Query_Data_SELECT.pdf`
- `Docs/03_Data_Definition_DDL.pdf`
- `Docs/04_Data_Manipulation_DML.pdf`

The `Customers` table uses the same teaching fields shown in the SELECT deck: `id`, `name`, `country`, and `score`. The `Accounts` and `Transactions` tables extend the same dataset for banking-style practice.

## Learning objectives

By the end of this lab, you should be able to:

- Explain the difference between DDL, DML, and DQL.
- Recognize common SQL Server data types and how they relate to Python data types.
- Create a SQL Server database and tables.
- Define primary keys, foreign keys, default values, and basic constraints.
- Insert records into related tables.
- Query records using `SELECT`, `WHERE`, `ORDER BY`, joins, and aggregates.
- Update and delete records safely using `WHERE`.
- Alter a table structure using `ALTER TABLE`.

## Prerequisites

- Linux environment with Docker installed.
- SQL Server 2022 container running locally.
- `sqlcmd` installed and available in your terminal.
- Course connection details:

```text
Server: localhost,1433
Username: sa
Password: StrongPassw0rd!2026
Database: TrainingDB
Trust server certificate: yes
```

Quick verification:

```bash
docker ps

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -Q "SELECT @@VERSION;"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -Q "SELECT name FROM sys.tables;"
```

## Folder structure

```text
Module 1/labs/sql-fundamentals/
├── README.md
├── 00_sql_server_data_types.sql
├── 00_sql_server_data_types.md
├── 01_ddl_create_database_and_tables.sql
├── 01_ddl_create_database_and_tables.md
├── 02_dml_insert_records.sql
├── 02_dml_insert_records.md
├── 03_dql_select_queries.sql
├── 03_dql_select_queries.md
├── 04_dml_update_delete_queries.sql
├── 04_dml_update_delete_queries.md
├── 05_ddl_alter_drop_optional.sql
└── 05_ddl_alter_drop_optional.md
```

## DDL, DML and DQL

**DDL** means Data Definition Language. DDL commands define or change database objects such as databases, tables, columns, constraints, and relationships. In this lab, `CREATE DATABASE`, `CREATE TABLE`, `ALTER TABLE`, and `DROP TABLE` are DDL examples.

**DML** means Data Manipulation Language. DML commands change the data inside tables. In this lab, `INSERT`, `UPDATE`, and `DELETE` are DML examples.

**DQL** means Data Query Language. DQL commands retrieve data from tables. In this lab, `SELECT` is the main DQL command.

## Run the lab scripts

Run these commands from the project root so the paths with spaces work correctly:

```bash
cd "$HOME/Desktop/Trainingcred Institute"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/00_sql_server_data_types.sql"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/01_ddl_create_database_and_tables.sql"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/02_dml_insert_records.sql"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/03_dql_select_queries.sql"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/04_dml_update_delete_queries.sql"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/05_ddl_alter_drop_optional.sql"
```

## Expected learning outcomes

After completing the scripts, you should understand how a small SQL Server database is created, populated, queried, and safely modified. You should also be able to run the SELECT deck examples against a matching `Customers` table and connect those SQL concepts to a simple banking-style dataset containing customers, accounts, and transactions.

## Safety notes

- Always preview the rows you plan to change before running `UPDATE`.
- Always use a `WHERE` clause with `UPDATE` unless you intentionally want to update every row.
- Always use a `WHERE` clause with `DELETE` unless you intentionally want to delete every row.
- Treat `DROP` as destructive because it removes database objects.
- In real systems, take a backup and confirm permissions before running destructive DDL or DML.

## Troubleshooting

### SQL Server container not running

Check running containers:

```bash
docker ps
```

If SQL Server is not listed, start the container using the setup instructions for this course.

### Login failed

Confirm the username and password are correct:

```text
Username: sa
Password: StrongPassw0rd!2026
```

Also confirm the SQL Server container has finished starting. SQL Server can take a short time before it accepts logins.

### Database not found

Run the first script before the other scripts:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/01_ddl_create_database_and_tables.sql"
```

Then verify the database tables:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -Q "SELECT name FROM sys.tables;"
```

### ODBC/driver issue

If Python or `sqlcmd` reports a driver error, confirm the Microsoft ODBC Driver for SQL Server is installed. For Python connections, confirm your connection string uses trust server certificate settings for the local Docker lab.

### Path with spaces in folder names

The folder name `Module 1` contains a space, so quote the script path:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/labs/sql-fundamentals/01_ddl_create_database_and_tables.sql"
```

Run commands from:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
```
