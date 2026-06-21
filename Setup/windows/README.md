# Windows Environment Setup Guide

## Transact-SQL and Python Programming Training Course

This guide explains how to set up the Windows development environment for the **Transact-SQL and Python Programming Training Course**.

The Windows setup uses:

* SQL Server Developer or Express
* SQL Server Management Studio, SSMS
* Visual Studio Code
* VS Code MSSQL extension
* Python
* Microsoft ODBC Driver 18 for SQL Server
* Python virtual environment
* Python libraries for database connectivity, data analysis, reporting, APIs, automation, and testing

---

# 1. Recommended Course Folder Structure

The course folder should be organized like this:

```text
Trainingcred Institute/
│
├── Setup/
│   ├── requirements.txt
│   ├── .env.example
│   │
│   ├── linux/
│   │   ├── README.md
│   │   └── docker-compose.yml
│   │
│   └── windows/
│       └── README.md
│
├── Module 1/
│   ├── README.md
│   └── Labs/
│       ├── lab 1/
│       │   ├── README.md
│       │   ├── 01_create_trainingdb.sql
│       │   └── test_connection.py
│       │
│       └── lab 2/
│           └── README.md
│
├── Module 2/
│   ├── README.md
│   └── Labs/
│
...
│
└── Module 10/
    ├── README.md
    └── Labs/
```

The course uses one Python virtual environment for all modules:

```text
Trainingcred Institute\.venv\
```

---

# 2. Required Downloads

Download and install the following tools.

## 2.1 SQL Server Developer or Express

Download SQL Server from Microsoft:

```text
https://www.microsoft.com/en-us/sql-server/sql-server-downloads
```

Recommended option:

```text
SQL Server Developer
```

Use **Developer Edition** for training, development, and testing.

Alternative:

```text
SQL Server Express
```

Use **Express Edition** if the machine has limited resources or only needs a lightweight SQL Server installation.

---

## 2.2 SQL Server Management Studio, SSMS

Download SSMS from Microsoft:

```text
https://learn.microsoft.com/en-us/ssms/install/install
```

Direct SSMS 22 installer link:

```text
https://aka.ms/ssms/22/release/vs_SSMS.exe
```

SSMS is the main graphical tool for working with SQL Server on Windows.

You will use SSMS to:

* Connect to SQL Server
* Create databases
* Create tables
* Run T-SQL queries
* View query results
* Manage database objects
* Run stored procedures
* View execution plans

---

## 2.3 Visual Studio Code

Download VS Code:

```text
https://code.visualstudio.com/download
```

VS Code will be used for:

* Python coding
* SQL scripts
* Markdown README files
* Jupyter notebooks
* Git integration
* Running course lab files

---

## 2.4 Python

Download Python:

```text
https://www.python.org/downloads/
```

During installation, make sure you tick:

```text
Add python.exe to PATH
```

This is important because it allows you to run Python from PowerShell or Command Prompt.

---

## 2.5 Microsoft ODBC Driver 18 for SQL Server

Download Microsoft ODBC Driver 18:

```text
https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server
```

For most Windows laptops, download:

```text
Microsoft ODBC Driver 18 for SQL Server (x64)
```

The ODBC driver is required so Python can connect to SQL Server using packages such as `pyodbc`.

---

## 2.6 Git for Windows

Download Git:

```text
https://git-scm.com/install/windows
```

Git will be used for version control and tracking lab changes.

---

# 3. Install SQL Server

Run the SQL Server installer downloaded from Microsoft.

Recommended installation option:

```text
Developer Edition
```

During setup:

1. Choose **Basic** for a simple installation, or **Custom** for specific installation settings.
2. Wait for SQL Server installation to complete.
3. Keep note of the installed instance name.

Common instance names:

```text
localhost
localhost\SQLEXPRESS
```

Use:

```text
localhost
```

if you installed SQL Server as the default instance.

Use:

```text
localhost\SQLEXPRESS
```

if you installed SQL Server Express as a named instance.

---

# 4. Install SSMS

Run the SSMS installer:

```text
vs_SSMS.exe
```

Steps:

1. Double-click `vs_SSMS.exe`.
2. Allow administrator permission if prompted.
3. Click **Install**.
4. Wait for installation to complete.
5. Restart the computer if requested.

After installation, open:

```text
SQL Server Management Studio
```

---

# 5. Connect to SQL Server Using SSMS

Open SSMS and connect using one of the following options.

## Option A: Windows Authentication

Use this if SQL Server is installed locally on your machine.

```text
Server type: Database Engine
Server name: localhost
Authentication: Windows Authentication
```

If you installed SQL Server Express, use:

```text
Server name: localhost\SQLEXPRESS
Authentication: Windows Authentication
```

Click:

```text
Connect
```

---

## Option B: SQL Server Authentication

Use this for SQL Server Authentication.

Example:

```text
Server type: Database Engine
Server name: localhost
Authentication: SQL Server Authentication
Login: sa
Password: StrongPassw0rd!2026
Trust server certificate: Tick/Enable
```

If using SQL Server Express:

```text
Server name: localhost\SQLEXPRESS
```

---

# 6. Create a Course SQL Login

If you are connected using Windows Authentication, you can create a course login for Python and lab work.

In SSMS, open a new query and run:

```sql
USE master;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.sql_logins
    WHERE name = 'course_user'
)
BEGIN
    CREATE LOGIN course_user
    WITH PASSWORD = 'StrongPassw0rd!2026',
    CHECK_POLICY = OFF;
END
GO
```

This creates a SQL Server login called:

```text
course_user
```

Password:

```text
StrongPassw0rd!2026
```

This password is for training only. Do not use it in production systems.

---

# 7. Create Module 1 Training Database

Open this file:

```text
Module 1\Labs\lab 1\01_create_trainingdb.sql
```

Add the following SQL:

```sql
IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END
GO

USE TrainingDB;
GO

IF OBJECT_ID('Customers', 'U') IS NOT NULL
BEGIN
    DROP TABLE Customers;
END
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    City VARCHAR(50),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

INSERT INTO Customers (FirstName, LastName, Email, City)
VALUES
('Tariro', 'Moyo', 'tariro.moyo@email.com', 'Harare'),
('Blessing', 'Dube', 'blessing.dube@email.com', 'Bulawayo'),
('Nyasha', 'Sibanda', 'nyasha.sibanda@email.com', 'Mutare'),
('Farai', 'Chikowore', 'farai.chikowore@email.com', 'Gweru');
GO

SELECT * FROM Customers;
GO
```

Run the script in SSMS.

Expected result:

```text
4 customer records should be displayed.
```

---

# 8. Give the Course Login Access to TrainingDB

If you created `course_user`, run this in SSMS:

```sql
USE TrainingDB;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'course_user'
)
BEGIN
    CREATE USER course_user FOR LOGIN course_user;
END
GO

ALTER ROLE db_owner ADD MEMBER course_user;
GO
```

This allows `course_user` to access and modify the `TrainingDB` database.

---

# 9. Install Microsoft ODBC Driver 18

Download and install:

```text
Microsoft ODBC Driver 18 for SQL Server (x64)
```

Official download page:

```text
https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server
```

After installation, confirm the driver exists.

Open PowerShell and run:

```powershell
Get-OdbcDriver | Where-Object Name -Like "*SQL Server*"
```

Expected result should include:

```text
ODBC Driver 18 for SQL Server
```

---

# 10. Install VS Code Extensions

Open PowerShell and run:

```powershell
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension ms-mssql.mssql
code --install-extension ms-azuretools.vscode-docker
code --install-extension eamodio.gitlens
code --install-extension redhat.vscode-yaml
code --install-extension yzhang.markdown-all-in-one
```

If `code` is not recognized, open VS Code manually and install the extensions from the Extensions tab.

## Required VS Code Extensions

| Extension           | Purpose                                                      |
| ------------------- | ------------------------------------------------------------ |
| Python              | Python coding, debugging, testing, and interpreter selection |
| Pylance             | Python IntelliSense, autocomplete, and type checking         |
| Jupyter             | Notebook support for Python labs and data analysis           |
| SQL Server / MSSQL  | Connect to SQL Server and run T-SQL queries inside VS Code   |
| Docker              | Optional container support                                   |
| GitLens             | Better Git history and source control                        |
| YAML                | Useful for setup files and Docker-related configuration      |
| Markdown All in One | Better README and Markdown editing                           |

---

# 11. Connect VS Code to SQL Server

Open VS Code.

1. Open the **SQL Server** extension from the left sidebar.
2. Select **Add Connection**.
3. Use one of the following connection setups.

## Option A: SQL Login

```text
Server: localhost
Authentication Type: SQL Login
User: course_user
Password: StrongPassw0rd!2026
Database: TrainingDB
Trust Server Certificate: True
```

If using SQL Server Express:

```text
Server: localhost\SQLEXPRESS
```

## Option B: Windows Authentication

```text
Server: localhost
Authentication Type: Windows Authentication
Database: TrainingDB
Trust Server Certificate: True
```

If using SQL Server Express:

```text
Server: localhost\SQLEXPRESS
```

After connecting, create a new SQL file and run:

```sql
USE TrainingDB;
GO

SELECT * FROM Customers;
GO
```

Expected result:

```text
The Customers table records should be displayed.
```

---

# 12. Create One Python Virtual Environment for the Whole Course

Open PowerShell and go to the course root folder:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
```

Create the virtual environment:

```powershell
py -3 -m venv .venv
```

Activate it:

```powershell
.\.venv\Scripts\Activate.ps1
```

If PowerShell blocks activation, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then activate again:

```powershell
.\.venv\Scripts\Activate.ps1
```

When the virtual environment is active, PowerShell should show:

```text
(.venv)
```

Upgrade pip:

```powershell
python -m pip install --upgrade pip
```

---

# 13. Create the Course Requirements File

Open:

```text
Setup\requirements.txt
```

Add:

```text
pyodbc
pandas
numpy
sqlalchemy
python-dotenv
openpyxl
jupyterlab
matplotlib
seaborn
scipy
scikit-learn
requests
beautifulsoup4
jinja2
schedule
pytest
```

Install the libraries:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt
```

Test key libraries:

```powershell
python -c "import pyodbc, pandas, sqlalchemy; print('Python database setup is working')"
```

Expected result:

```text
Python database setup is working
```

---

# 14. Create the Environment Variable Template

Open:

```text
Setup\.env.example
```

Add this version if using SQL login:

```env
DB_SERVER=localhost
DB_NAME=TrainingDB
DB_USER=course_user
DB_PASSWORD=StrongPassw0rd!2026
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_AUTH=sql
```

If using SQL Server Express, use:

```env
DB_SERVER=localhost\SQLEXPRESS
DB_NAME=TrainingDB
DB_USER=course_user
DB_PASSWORD=StrongPassw0rd!2026
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_AUTH=sql
```

Copy the template to create the real local `.env` file:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
Copy-Item Setup\.env.example .env
```

The `.env` file should not be pushed to GitHub because it contains passwords.

---

# 15. Create Root `.gitignore`

Create or open:

```text
Trainingcred Institute\.gitignore
```

Add:

```gitignore
.venv/
.env
__pycache__/
*.pyc
*.xlsx
*.csv
*.log
.ipynb_checkpoints/
```

This prevents virtual environments, passwords, generated reports, logs, and temporary Python files from being committed.

---

# 16. Create Module 1 Python Connection Test

Open:

```text
Module 1\Labs\lab 1\test_connection.py
```

Add:

```python
import os
import pyodbc
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

server = os.getenv("DB_SERVER")
database = os.getenv("DB_NAME")
username = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")
driver = os.getenv("DB_DRIVER")
auth = os.getenv("DB_AUTH", "sql").lower()

if auth == "windows":
    connection_string = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )
else:
    connection_string = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"UID={username};"
        f"PWD={password};"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )

try:
    conn = pyodbc.connect(connection_string)

    query = """
    SELECT CustomerID, FirstName, LastName, Email, City, CreatedAt
    FROM Customers;
    """

    df = pd.read_sql(query, conn)

    print(df)

    os.makedirs("reports", exist_ok=True)
    df.to_excel("reports/customers_report.xlsx", index=False)

    print("Connection successful.")
    print("Excel report created: reports/customers_report.xlsx")

    conn.close()

except Exception as e:
    print("Connection failed.")
    print(e)
```

Run the script:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
python "Module 1\Labs\lab 1\test_connection.py"
```

Expected result:

```text
Connection successful.
Excel report created: reports/customers_report.xlsx
```

---

# 17. Optional: Use Windows Authentication in Python

If you prefer Windows Authentication instead of SQL login, update `.env` like this:

```env
DB_SERVER=localhost
DB_NAME=TrainingDB
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_AUTH=windows
```

If using SQL Server Express:

```env
DB_SERVER=localhost\SQLEXPRESS
DB_NAME=TrainingDB
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_AUTH=windows
```

The same Python script will work because it checks the value of:

```text
DB_AUTH
```

---

# 18. Useful SSMS Tasks

## Create a new query

1. Open SSMS.
2. Connect to SQL Server.
3. Click **New Query**.
4. Select the target database.
5. Write and run SQL.

Shortcut:

```text
F5
```

runs the current query.

---

## View databases

In Object Explorer:

```text
Server > Databases
```

You should see:

```text
TrainingDB
```

---

## View tables

In Object Explorer:

```text
Databases > TrainingDB > Tables
```

You should see:

```text
dbo.Customers
```

---

## Run a quick test

```sql
USE TrainingDB;
GO

SELECT * FROM Customers;
GO
```

---

# 19. Useful PowerShell Commands

Check Python:

```powershell
python --version
py --version
pip --version
```

Check Git:

```powershell
git --version
```

Activate virtual environment:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
```

Install requirements:

```powershell
pip install -r Setup\requirements.txt
```

Check ODBC drivers:

```powershell
Get-OdbcDriver | Where-Object Name -Like "*SQL Server*"
```

Run Module 1 Python lab:

```powershell
python "Module 1\Labs\lab 1\test_connection.py"
```

Open course folder in VS Code:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
code .
```

---

# 20. Common Errors and Fixes

## Error: `python` is not recognized

Cause:

```text
Python was not added to PATH.
```

Fix:

1. Reinstall Python.
2. Tick **Add python.exe to PATH** during installation.
3. Restart PowerShell.

Then test:

```powershell
python --version
```

---

## Error: PowerShell cannot activate `.venv`

Example:

```text
running scripts is disabled on this system
```

Fix:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then activate again:

```powershell
.\.venv\Scripts\Activate.ps1
```

---

## Error: ODBC Driver not found

Check installed ODBC drivers:

```powershell
Get-OdbcDriver | Where-Object Name -Like "*SQL Server*"
```

Expected:

```text
ODBC Driver 18 for SQL Server
```

If missing, install Microsoft ODBC Driver 18 again:

```text
https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server
```

---

## Error: Login failed for user

Check:

* SQL Server is running.
* You are using the correct server name.
* You are using the correct username and password.
* `course_user` exists.
* `course_user` has access to `TrainingDB`.

Test in SSMS first before testing Python.

---

## Error: Cannot connect to `localhost`

Try:

```text
localhost
```

or:

```text
localhost\SQLEXPRESS
```

or:

```text
127.0.0.1
```

If using SQL Server Express, the most common server name is:

```text
localhost\SQLEXPRESS
```

---

## Error: Certificate or encryption error

In VS Code MSSQL, enable:

```text
Trust Server Certificate: True
```

In Python, make sure the connection string includes:

```text
Encrypt=yes;
TrustServerCertificate=yes;
```

---

## Error: VS Code uses the wrong Python interpreter

In VS Code:

1. Press `Ctrl + Shift + P`.
2. Search for:

```text
Python: Select Interpreter
```

3. Select:

```text
Trainingcred Institute\.venv\Scripts\python.exe
```

---

# 21. Final Setup Checklist

Before starting Module 1 labs, confirm the following:

## SQL Server

Open SSMS and connect successfully using either:

```text
localhost
```

or:

```text
localhost\SQLEXPRESS
```

## TrainingDB

Run:

```sql
USE TrainingDB;
GO

SELECT * FROM Customers;
GO
```

Expected:

```text
4 customer records
```

## ODBC Driver

Run in PowerShell:

```powershell
Get-OdbcDriver | Where-Object Name -Like "*SQL Server*"
```

Expected:

```text
ODBC Driver 18 for SQL Server
```

## Python Environment

Run:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
python -c "import pyodbc, pandas, sqlalchemy; print('Python setup complete')"
```

Expected:

```text
Python setup complete
```

## Python SQL Server Connection

Run:

```powershell
python "Module 1\Labs\lab 1\test_connection.py"
```

Expected:

```text
Connection successful.
Excel report created: reports/customers_report.xlsx
```

## VS Code MSSQL

Connect using:

```text
Server: localhost
Authentication: SQL Login
User: course_user
Password: StrongPassw0rd!2026
Database: TrainingDB
Trust Server Certificate: True
```

or, for SQL Server Express:

```text
Server: localhost\SQLEXPRESS
Authentication: SQL Login
User: course_user
Password: StrongPassw0rd!2026
Database: TrainingDB
Trust Server Certificate: True
```

If all checks pass, the Windows environment is ready for the Transact-SQL and Python Programming course.
