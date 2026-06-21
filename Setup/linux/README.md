# Linux Environment Setup Guide

## Transact-SQL and Python Programming Training Course

This guide explains how to set up the Linux development environment for the **Transact-SQL and Python Programming Training Course**.

The Linux setup uses:

* Visual Studio Code for coding and teaching
* Docker for running SQL Server
* SQL Server 2022 Developer container
* Microsoft ODBC Driver 18 for SQL Server
* Python virtual environment
* Python libraries for database connectivity, data analysis, reporting, APIs, and automation
* DBeaver Community as an optional graphical database client
* VS Code extensions for SQL, Python, Docker, Git, Markdown, YAML, and notebooks

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

The course uses **one Python virtual environment** for all modules:

```text
Trainingcred Institute/.venv/
```

---

# 2. Open the Course Folder

Open a terminal and go to the main course folder:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
```

Check that you are in the correct location:

```bash
pwd
```

Expected result:

```text
/home/your-username/Desktop/Trainingcred Institute
```

This is the root folder where the course virtual environment will be created.

---

# 3. Install Basic Linux Packages

Run:

```bash
sudo apt update
sudo apt install -y curl wget git ca-certificates gnupg lsb-release python3 python3-pip python3-venv unixodbc-dev
```

## What this command does

| Package           | Purpose                                                   |
| ----------------- | --------------------------------------------------------- |
| `curl`            | Downloads files from the internet using terminal commands |
| `wget`            | Alternative tool for downloading files                    |
| `git`             | Version control for tracking code changes                 |
| `ca-certificates` | Helps Linux trust secure HTTPS connections                |
| `gnupg`           | Handles signing keys for trusted repositories             |
| `lsb-release`     | Detects Ubuntu/Linux distribution information             |
| `python3`         | Installs Python 3                                         |
| `python3-pip`     | Installs Python package manager                           |
| `python3-venv`    | Allows creation of Python virtual environments            |
| `unixodbc-dev`    | Required for building and using ODBC database drivers     |

Check installed versions:

```bash
python3 --version
pip3 --version
git --version
```

---

# 4. Check Whether Docker Is Already Installed

Before installing Docker, check if it is already available:

```bash
docker --version
docker ps
docker compose version
```

## Meaning of the commands

| Command                  | Purpose                                    |
| ------------------------ | ------------------------------------------ |
| `docker --version`       | Checks installed Docker version            |
| `docker ps`              | Shows running Docker containers            |
| `docker compose version` | Checks whether Docker Compose is available |

If these commands work, Docker is already installed and you should not reinstall it.

---

# 5. Install Docker Only If Missing

If Docker is not installed, run:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
```

Start Docker:

```bash
sudo systemctl start docker
```

Enable Docker to start automatically when the computer boots:

```bash
sudo systemctl enable docker
```

Allow your user account to run Docker commands without typing `sudo` every time:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Test Docker:

```bash
docker ps
docker run hello-world
```

## What these commands do

| Command                         | Purpose                                                  |
| ------------------------------- | -------------------------------------------------------- |
| `sudo systemctl start docker`   | Starts Docker immediately                                |
| `sudo systemctl enable docker`  | Starts Docker automatically on boot                      |
| `sudo usermod -aG docker $USER` | Adds current user to the Docker group                    |
| `newgrp docker`                 | Applies Docker group permission without logging out      |
| `docker run hello-world`        | Runs a small test container to confirm Docker is working |

---

# 6. Create the SQL Server Docker Compose File

Go to the Linux setup folder:

```bash
cd "$HOME/Desktop/Trainingcred Institute/Setup/linux"
```

Open or create the Docker Compose file:

```bash
code docker-compose.yml
```

Paste this content:

```yaml
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: ires-sqlserver
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_SA_PASSWORD: "StrongPassw0rd!2026"
      MSSQL_PID: "Developer"
    ports:
      - "1433:1433"
    volumes:
      - ires_sqlserver_data:/var/opt/mssql

volumes:
  ires_sqlserver_data:
```

## What this file does

| Line / Section                                      | Purpose                                                             |
| --------------------------------------------------- | ------------------------------------------------------------------- |
| `image: mcr.microsoft.com/mssql/server:2022-latest` | Uses Microsoft SQL Server 2022 container image                      |
| `container_name: ires-sqlserver`                    | Gives the container a clear name                                    |
| `ACCEPT_EULA: "Y"`                                  | Accepts Microsoft SQL Server license agreement                      |
| `MSSQL_SA_PASSWORD`                                 | Sets the SQL Server `sa` account password                           |
| `MSSQL_PID: "Developer"`                            | Uses SQL Server Developer edition                                   |
| `1433:1433`                                         | Maps SQL Server port from container to host machine                 |
| `ires_sqlserver_data`                               | Keeps database files persistent even after restarting the container |

> Note: The password above is for training purposes. In real systems, use a stronger private password and do not commit passwords to GitHub.

---

# 7. Start SQL Server

From the folder containing `docker-compose.yml`, run these commands to start SQL Server and confirm the container is running:

```bash
cd "$HOME/Desktop/Trainingcred Institute/Setup/linux"
docker compose up -d
docker ps
```

## What this command does

| Part             | Meaning                                                         |
| ---------------- | --------------------------------------------------------------- |
| `docker compose` | Uses Docker Compose                                             |
| `up`             | Creates and starts the services defined in `docker-compose.yml` |
| `-d`             | Runs the container in the background                            |

The `docker ps` output should show the running SQL Server container.

Expected result should include:

```text
ires-sqlserver
0.0.0.0:1433->1433/tcp
```

View SQL Server logs:

```bash
docker logs -f ires-sqlserver
```

Wait until the logs show something similar to:

```text
SQL Server is now ready for client connections.
```

Stop viewing logs using:

```text
CTRL + C
```

---

# 8. Install Microsoft ODBC Driver 18 and SQL Tools

Python needs the Microsoft ODBC Driver to connect to SQL Server using packages such as `pyodbc`.

Run the following commands:

```bash
curl -sSL -O https://packages.microsoft.com/config/ubuntu/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)/packages-microsoft-prod.deb

sudo dpkg -i packages-microsoft-prod.deb

rm packages-microsoft-prod.deb

sudo apt update

sudo ACCEPT_EULA=Y apt install -y msodbcsql18 mssql-tools18 unixodbc-dev
```

## What these commands do

| Command                                       | Purpose                                                                |
| --------------------------------------------- | ---------------------------------------------------------------------- |
| `curl -sSL -O ...packages-microsoft-prod.deb` | Downloads Microsoft package repository configuration                   |
| `sudo dpkg -i packages-microsoft-prod.deb`    | Installs Microsoft package repository into Ubuntu                      |
| `rm packages-microsoft-prod.deb`              | Removes the downloaded installer file after installation               |
| `sudo apt update`                             | Refreshes package list, including Microsoft packages                   |
| `sudo ACCEPT_EULA=Y apt install ...`          | Installs ODBC Driver 18, SQL command tools, and ODBC development files |

Add SQL Server tools to your terminal PATH:

```bash
grep -qxF 'export PATH="$PATH:/opt/mssql-tools18/bin"' ~/.bashrc || echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

source ~/.bashrc
```

## What this command does

| Command                   | Purpose                                |
| ------------------------- | -------------------------------------- |
| `grep -qxF ... ~/.bashrc` | Checks if the PATH line already exists |
| `echo ... >> ~/.bashrc`   | Adds SQL tools path if missing         |
| `source ~/.bashrc`        | Reloads terminal settings immediately  |

Test that `sqlcmd` is available:

```bash
which sqlcmd
sqlcmd -?
```

Expected path:

```text
/opt/mssql-tools18/bin/sqlcmd
```

---

# 9. Test SQL Server from Terminal

Make sure the SQL Server container is running:

```bash
docker ps
```

Then test SQL Server:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -Q "SELECT @@VERSION;"
```

## What this command does

| Option                     | Purpose                                           |
| -------------------------- | ------------------------------------------------- |
| `-S localhost,1433`        | Connects to SQL Server on local machine port 1433 |
| `-U sa`                    | Uses SQL Server admin username                    |
| `-P 'StrongPassw0rd!2026'` | Provides the password                             |
| `-C`                       | Trusts the server certificate                     |
| `-Q "SELECT @@VERSION;"`   | Runs the SQL query and exits                      |

Expected output should show SQL Server version details, for example:

```text
Microsoft SQL Server 2022 ...
Developer Edition ...
Linux ...
```

---

# 10. Install VS Code Extensions

Open the course folder in VS Code:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
code .
```

Install required extensions:

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

## What these extensions do

| Extension                     | Purpose                                                             |
| ----------------------------- | ------------------------------------------------------------------- |
| `ms-python.python`            | Python development, debugging, testing, and interpreter selection   |
| `ms-python.vscode-pylance`    | Python IntelliSense, autocomplete, and type checking                |
| `ms-toolsai.jupyter`          | Jupyter notebook support for Python labs and data analysis          |
| `ms-mssql.mssql`              | SQL Server connection and T-SQL query execution in VS Code          |
| `ms-azuretools.vscode-docker` | Docker container, image, and compose file management in VS Code     |
| `eamodio.gitlens`             | Better Git history, commit tracking, and code ownership information |
| `redhat.vscode-yaml`          | YAML support for editing `docker-compose.yml`                       |
| `yzhang.markdown-all-in-one`  | Better README writing, Markdown preview, tables, and formatting     |

Restart VS Code after installing the extensions.

---

# 11. Connect VS Code to SQL Server

In VS Code:

1. Open the **SQL Server** extension from the left sidebar.
2. Select **Add Connection**.
3. Enter the following details:

```text
Server: localhost,1433
Authentication Type: SQL Login
User: sa
Password: StrongPassw0rd!2026
Database: master
Trust Server Certificate: True
```

After connecting, create a new SQL file and test:

```sql
SELECT @@VERSION;
GO
```

You can now run SQL queries directly inside VS Code.

---

# 12. Install DBeaver Community GUI

DBeaver is an optional graphical database client similar to pgAdmin, but it supports SQL Server and many other databases.

Install DBeaver using Snap:

```bash
sudo snap install dbeaver-ce
```

Open DBeaver from the applications menu or run:

```bash
dbeaver-ce
```

## Connect DBeaver to SQL Server

In DBeaver:

1. Click **New Database Connection**.
2. Choose **SQL Server**.
3. Use the following connection details:

```text
Host: localhost
Port: 1433
Database: master
Username: sa
Password: StrongPassw0rd!2026
```

4. Click **Test Connection**.
5. If DBeaver asks to download the SQL Server driver, allow it.
6. Click **Finish**.

DBeaver can now be used to browse databases, tables, columns, and run SQL queries through a graphical interface.

---

# 13. Create One Python Virtual Environment for the Whole Course

Go to the course root folder:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
```

Create the virtual environment:

```bash
python3 -m venv .venv
```

Activate the virtual environment:

```bash
source .venv/bin/activate
```

Upgrade pip:

```bash
pip install --upgrade pip
```

## What these commands do

| Command                     | Purpose                                      |
| --------------------------- | -------------------------------------------- |
| `python3 -m venv .venv`     | Creates a virtual environment called `.venv` |
| `source .venv/bin/activate` | Activates the virtual environment            |
| `pip install --upgrade pip` | Updates pip inside the virtual environment   |

When the virtual environment is active, your terminal shows:

```text
(.venv)
```

---

# 14. Create the Course Requirements File

The full course requirements file should be located at:

```text
Setup/requirements.txt
```

Open it:

```bash
code "$HOME/Desktop/Trainingcred Institute/Setup/requirements.txt"
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

Install the packages:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

## What the packages do

| Package          | Purpose                                         |
| ---------------- | ----------------------------------------------- |
| `pyodbc`         | Connects Python to SQL Server using ODBC        |
| `pandas`         | Data cleaning, analysis, and table manipulation |
| `numpy`          | Numerical operations                            |
| `sqlalchemy`     | Database toolkit and connection abstraction     |
| `python-dotenv`  | Reads database credentials from `.env` files    |
| `openpyxl`       | Allows pandas to export Excel files             |
| `jupyterlab`     | Interactive notebooks for teaching and demos    |
| `matplotlib`     | Data visualization                              |
| `seaborn`        | Statistical data visualization                  |
| `scipy`          | Scientific and statistical calculations         |
| `scikit-learn`   | Basic machine learning workflows                |
| `requests`       | API requests                                    |
| `beautifulsoup4` | Web scraping and HTML parsing                   |
| `jinja2`         | Template-based report generation                |
| `schedule`       | Simple Python job scheduling                    |
| `pytest`         | Testing Python code                             |

Test key packages:

```bash
python -c "import pyodbc, pandas, sqlalchemy; print('Python database setup is working')"
```

---

# 15. Create the Environment Variable Template

The template file should be located at:

```text
Setup/.env.example
```

Open it:

```bash
code "$HOME/Desktop/Trainingcred Institute/Setup/.env.example"
```

Add:

```env
DB_SERVER=localhost,1433
DB_NAME=TrainingDB
DB_USER=sa
DB_PASSWORD=StrongPassw0rd!2026
DB_DRIVER=ODBC Driver 18 for SQL Server
```

Copy this file to the course root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
cp Setup/.env.example .env
```

The real `.env` file should not be pushed to GitHub because it contains database credentials.

---

# 16. Create a Root `.gitignore`

Go to the course root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
```

Create or open `.gitignore`:

```bash
code .gitignore
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

## What this ignores

| Entry                 | Purpose                                                 |
| --------------------- | ------------------------------------------------------- |
| `.venv/`              | Prevents virtual environment files from being committed |
| `.env`                | Prevents passwords and credentials from being committed |
| `__pycache__/`        | Ignores Python cache folders                            |
| `*.pyc`               | Ignores compiled Python files                           |
| `*.xlsx`              | Ignores generated Excel reports                         |
| `*.csv`               | Ignores generated CSV exports                           |
| `*.log`               | Ignores log files                                       |
| `.ipynb_checkpoints/` | Ignores Jupyter autosave files                          |

---

# 17. Create Module 1 Lab 1 SQL File

Go to the course root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
```

Open the Module 1 Lab 1 SQL file:

```bash
code "Module 1/Labs/lab 1/01_create_trainingdb.sql"
```

Add:

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

Run it from terminal:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/Labs/lab 1/01_create_trainingdb.sql"
```

Test the database:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -Q "SELECT * FROM Customers;"
```

---

# 18. Create Module 1 Lab 1 Python Connection Test

Open the Python file:

```bash
code "Module 1/Labs/lab 1/test_connection.py"
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

Run it:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
python "Module 1/Labs/lab 1/test_connection.py"
```

Expected result:

```text
Connection successful.
Excel report created: reports/customers_report.xlsx
```

---

# 19. Useful SQL Server and Docker Commands

## Start SQL Server

```bash
cd "$HOME/Desktop/Trainingcred Institute/Setup/linux"
docker compose up -d
```

Starts the SQL Server container in the background.

## Stop SQL Server

```bash
cd "$HOME/Desktop/Trainingcred Institute/Setup/linux"
docker compose down
```

Stops and removes the container, but keeps the database volume.

## Start existing container

```bash
docker start ires-sqlserver
```

Starts an already-created SQL Server container.

## Stop existing container

```bash
docker stop ires-sqlserver
```

Stops the running SQL Server container.

## View running containers

```bash
docker ps
```

Shows currently running containers.

## View all containers

```bash
docker ps -a
```

Shows running and stopped containers.

## View SQL Server logs

```bash
docker logs -f ires-sqlserver
```

Shows SQL Server startup and runtime logs.

## Remove SQL Server and delete data

```bash
cd "$HOME/Desktop/Trainingcred Institute/Setup/linux"
docker compose down -v
```

This removes the SQL Server container and deletes the database volume.

Use this carefully because it deletes saved SQL Server data.

---

# 20. Useful SQLCMD Commands

## Check SQL Server version

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -Q "SELECT @@VERSION;"
```

## Connect interactively

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C
```

Then inside `sqlcmd`:

```sql
SELECT name FROM sys.databases;
GO
```

Exit:

```sql
EXIT
```

## Run a SQL file

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 1/Labs/lab 1/01_create_trainingdb.sql"
```

## Query a specific database

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -Q "SELECT * FROM Customers;"
```

---

# 21. Common Errors and Fixes

## Error: Docker permission denied

Example:

```text
permission denied while trying to connect to the Docker daemon socket
```

Fix:

```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
```

---

## Error: Port 1433 already in use

Check what is using the port:

```bash
sudo lsof -i :1433
```

Change the port in `docker-compose.yml`:

```yaml
ports:
  - "1434:1433"
```

Then connect using:

```text
localhost,1434
```

---

## Error: ODBC Driver not found

Check installed ODBC drivers:

```bash
python -c "import pyodbc; print(pyodbc.drivers())"
```

Expected output should include:

```text
ODBC Driver 18 for SQL Server
```

If it is missing, reinstall the driver:

```bash
sudo ACCEPT_EULA=Y apt install -y msodbcsql18 mssql-tools18 unixodbc-dev
```

---

## Error: SQL Server login failed

Check:

```bash
docker ps
```

Confirm the container is running.

Also confirm that the password matches the one in `docker-compose.yml`:

```text
StrongPassw0rd!2026
```

---

## Error: Certificate verification failed

For `sqlcmd`, use:

```bash
-C
```

For Python connection strings, include:

```text
TrustServerCertificate=yes;
```

---

## Error: Python module not found

Example:

```text
ModuleNotFoundError: No module named 'pyodbc'
```

Fix:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

---

## Error: VS Code uses wrong Python interpreter

In VS Code:

1. Press `Ctrl + Shift + P`
2. Search for `Python: Select Interpreter`
3. Select:

```text
Trainingcred Institute/.venv/bin/python
```

---

# 22. Final Setup Checklist

Before starting Module 1 labs, confirm the following:

```bash
docker ps
```

Expected:

```text
ires-sqlserver   Up   0.0.0.0:1433->1433/tcp
```

Check SQL Server:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -Q "SELECT @@VERSION;"
```

Check Python packages:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
python -c "import pyodbc, pandas, sqlalchemy; print('Python setup complete')"
```

Check ODBC driver:

```bash
python -c "import pyodbc; print(pyodbc.drivers())"
```

Expected output should include:

```text
ODBC Driver 18 for SQL Server
```

Check DBeaver connection:

```text
Host: localhost
Port: 1433
Database: master
Username: sa
Password: StrongPassw0rd!2026
```

Check VS Code connection:

```text
Server: localhost,1433
Authentication Type: SQL Login
User: sa
Password: StrongPassw0rd!2026
Trust Server Certificate: True
```

If all checks pass, the Linux environment is ready for the Transact-SQL and Python Programming course.
