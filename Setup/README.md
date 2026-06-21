# Transact-SQL and Python Programming Training Course

## Course Environment Setup Guide

This repository contains setup instructions, module notes, and practical labs for the **Transact-SQL and Python Programming Training Course**.

The course uses:

* SQL Server for database programming
* Transact-SQL for querying and database automation
* Python for automation, data processing, reporting, APIs, and analytics
* Visual Studio Code for coding
* SSMS on Windows for SQL Server management
* DBeaver or VS Code MSSQL on Linux for SQL Server management
* One shared Python virtual environment for all modules

---

# 1. Course Folder Structure

The recommended folder structure is:

```text
Trainingcred Institute/
│
├── README.md
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

---

# 2. One Virtual Environment for the Whole Course

This course uses **one Python virtual environment** at the root of the `Trainingcred Institute` folder:

```text
Trainingcred Institute/.venv/
```

Do **not** create a separate virtual environment inside each module.

Using one virtual environment keeps the setup simple because all modules use the same Python libraries.

---

# 3. Required General Tools

Before starting the course, install the following tools.

## 3.1 Python

Python is required for all Python labs, database connection scripts, automation scripts, reporting tasks, API integration, and data analysis work.

Official download page:

```text
https://www.python.org/downloads/
```

Recommended:

```text
Python 3.10 or newer
```

On Windows, make sure to tick:

```text
Add python.exe to PATH
```

During installation.

Check Python after installation:

```bash
python --version
```

or:

```bash
python3 --version
```

---

## 3.2 Visual Studio Code

Visual Studio Code is used for:

* Python scripts
* SQL files
* Markdown README files
* Jupyter notebooks
* Git integration
* Course labs

Official download page:

```text
https://code.visualstudio.com/download
```

After installing VS Code, open the course folder:

### Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute"
code .
```

### Windows PowerShell

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
code .
```

---

## 3.3 Git

Git is used for version control and tracking lab work.

Official download page:

```text
https://git-scm.com/downloads
```

Check Git after installation:

```bash
git --version
```

---

## 3.4 SQL Server Tools

The SQL Server setup depends on the operating system.

### Linux

Linux setup uses:

* Docker
* SQL Server running in a Docker container
* Microsoft ODBC Driver 18
* `sqlcmd`
* DBeaver and/or VS Code MSSQL extension

Follow:

```text
Setup/linux/README.md
```

### Windows

Windows setup uses:

* SQL Server Developer or Express
* SQL Server Management Studio, SSMS
* Microsoft ODBC Driver 18
* VS Code MSSQL extension

Follow:

```text
Setup/windows/README.md
```

---

# 4. Install VS Code Extensions

Install the following VS Code extensions.

Open a terminal or PowerShell and run:

```bash
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension ms-mssql.mssql
code --install-extension ms-azuretools.vscode-docker
code --install-extension eamodio.gitlens
code --install-extension redhat.vscode-yaml
code --install-extension yzhang.markdown-all-in-one
```

## What the Extensions Do

| Extension           | Purpose                                                      |
| ------------------- | ------------------------------------------------------------ |
| Python              | Python coding, debugging, testing, and interpreter selection |
| Pylance             | Python IntelliSense, autocomplete, and type checking         |
| Jupyter             | Notebook support for Python demonstrations and data analysis |
| SQL Server / MSSQL  | Connect to SQL Server and run T-SQL queries in VS Code       |
| Docker              | View and manage Docker containers from VS Code               |
| GitLens             | Improved Git history and version control tools               |
| YAML                | Better support for Docker Compose and YAML files             |
| Markdown All in One | Better README writing and Markdown preview                   |

Restart VS Code after installing the extensions.

---

# 5. Create the Python Virtual Environment

Create the virtual environment from the root of the course folder.

## Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute"
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

When the environment is active, the terminal should show:

```text
(.venv)
```

## Windows PowerShell

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
```

If PowerShell blocks activation, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then activate again:

```powershell
.\.venv\Scripts\Activate.ps1
```

When the environment is active, PowerShell should show:

```text
(.venv)
```

---

# 6. Install Course Python Libraries

The course libraries are listed in:

```text
Setup/requirements.txt
```

Recommended contents:

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

Install the libraries after activating the virtual environment.

## Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

## Windows PowerShell

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt
```

Test the installation:

```bash
python -c "import pyodbc, pandas, sqlalchemy; print('Python database setup is working')"
```

Expected output:

```text
Python database setup is working
```

---

# 7. Environment Variables

Database credentials should be placed in a `.env` file.

The template file is:

```text
Setup/.env.example
```

Example contents:

```env
DB_SERVER=localhost,1433
DB_NAME=TrainingDB
DB_USER=sa
DB_PASSWORD=StrongPassw0rd!2026
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_AUTH=sql
```

Copy the template to the root folder.

## Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute"
cp Setup/.env.example .env
```

## Windows PowerShell

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
Copy-Item Setup\.env.example .env
```

The `.env` file should not be uploaded to GitHub because it contains database connection details.

---

# 8. Create Root `.gitignore`

Create a `.gitignore` file at the root of the course folder:

```text
Trainingcred Institute/.gitignore
```

Recommended contents:

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

# 9. Select the Python Interpreter in VS Code

After creating the virtual environment, select it in VS Code.

Steps:

1. Open VS Code.
2. Press:

```text
Ctrl + Shift + P
```

3. Search for:

```text
Python: Select Interpreter
```

4. Select the virtual environment interpreter.

## Linux Interpreter Path

```text
Trainingcred Institute/.venv/bin/python
```

## Windows Interpreter Path

```text
Trainingcred Institute\.venv\Scripts\python.exe
```

This ensures VS Code uses the course virtual environment.

---

# 10. Database Setup Instructions

The database setup is different for Linux and Windows.

## Linux Setup

Use:

```text
Setup/linux/README.md
```

Linux setup includes:

* Docker setup
* SQL Server 2022 container
* Microsoft ODBC Driver 18
* `sqlcmd`
* DBeaver setup
* VS Code MSSQL connection

## Windows Setup

Use:

```text
Setup/windows/README.md
```

Windows setup includes:

* SQL Server Developer or Express
* SSMS
* Microsoft ODBC Driver 18
* VS Code MSSQL connection
* Python-to-SQL Server connection

---

# 11. Quick Setup Checklist

Before starting Module 1, confirm the following.

## General Checks

```bash
python --version
pip --version
git --version
```

or on some Linux systems:

```bash
python3 --version
pip3 --version
git --version
```

## Virtual Environment Check

Activate the virtual environment.

### Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
```

### Windows PowerShell

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
```

Then run:

```bash
python -c "import pyodbc, pandas, sqlalchemy; print('Setup complete')"
```

Expected output:

```text
Setup complete
```

## SQL Server Check

### Linux

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -Q "SELECT @@VERSION;"
```

### Windows

Use SSMS or VS Code MSSQL and run:

```sql
SELECT @@VERSION;
GO
```

---

# 12. Running Module 1 Lab 1

After completing the setup, go to Module 1 Lab 1.

The SQL file is:

```text
Module 1/Labs/lab 1/01_create_trainingdb.sql
```

The Python connection test is:

```text
Module 1/Labs/lab 1/test_connection.py
```

## Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
python "Module 1/Labs/lab 1/test_connection.py"
```

## Windows PowerShell

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

# 13. Troubleshooting

## Python is not recognized

Reinstall Python and make sure it is added to PATH.

On Windows, tick:

```text
Add python.exe to PATH
```

During installation.

---

## VS Code uses the wrong Python

In VS Code:

```text
Ctrl + Shift + P
Python: Select Interpreter
```

Select:

### Linux

```text
Trainingcred Institute/.venv/bin/python
```

### Windows

```text
Trainingcred Institute\.venv\Scripts\python.exe
```

---

## `ModuleNotFoundError`

Example:

```text
ModuleNotFoundError: No module named 'pyodbc'
```

Fix:

### Linux

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

### Windows PowerShell

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt
```

---

## ODBC Driver not found

The Microsoft ODBC Driver 18 must be installed separately.

Linux users should follow:

```text
Setup/linux/README.md
```

Windows users should follow:

```text
Setup/windows/README.md
```

---

## SQL Server connection fails

Check:

* SQL Server is running
* The server name is correct
* The username and password are correct
* The database exists
* The ODBC Driver 18 is installed
* `TrustServerCertificate=yes` is included in Python connection strings

---

# 14. Recommended Learning Flow

Follow this order:

1. Complete this top-level setup guide.
2. Complete the correct operating system setup guide:

   * `Setup/linux/README.md`
   * `Setup/windows/README.md`
3. Start `Module 1`.
4. Complete `Module 1/Labs/lab 1`.
5. Continue through the remaining modules in order.

---

# 15. Course Readiness Confirmation

Ready for Module 1 when you can:

* Open the `Trainingcred Institute` folder in VS Code
* Activate the `.venv` virtual environment
* Import `pyodbc`, `pandas`, and `sqlalchemy`
* Connect to SQL Server
* Run a basic SQL query
* Execute the Module 1 Python connection script

Once all checks pass, the environment is ready.
