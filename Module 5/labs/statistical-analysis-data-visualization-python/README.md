# Statistical Analysis and Data Visualization with Python

This Module 5 lab uses notebooks to extract financial indicators from SQL Server, analyse them with Python, build charts, train a simple model, and prepare a short analytical report.

Guiding documents:

- `Transact-SQL training_program.pdf`
- `Transact-SQL  workbook.pdf`
- `Setup/requirements.txt`

## Learning Order

1. Prepare the SQL Server analysis dataset.
2. Run descriptive statistics, correlations, and hypothesis tests.
3. Build Matplotlib and Seaborn visualizations.
4. Train and evaluate a simple Scikit-learn model.
5. Analyse time series trends and create a final report.

## Files

```text
Module 5/labs/statistical-analysis-data-visualization-python/
├── README.md
├── .env
├── .env.windows
├── 01_setup_analysis_dataset.sql
├── analysis_utils.py
├── 01_statistics_scipy.ipynb
├── 02_visualization_matplotlib_seaborn.ipynb
├── 03_machine_learning_sklearn.ipynb
├── 04_time_series_and_report.ipynb
├── analytical_report_template.md
└── outputs/
```

## Linux Setup

```bash
cd "$HOME/Desktop/IRES"
source .venv/bin/activate
pip install -r Setup/requirements.txt

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 5/labs/statistical-analysis-data-visualization-python/01_setup_analysis_dataset.sql"
```

Run notebooks:

```bash
cd "$HOME/Desktop/IRES/Module 5/labs/statistical-analysis-data-visualization-python"
jupyter lab
```

## Windows Setup

If using SQL Server Express, change `.env.windows`:

```env
DB_SERVER=localhost\SQLEXPRESS
```

From PowerShell:

```powershell
cd "$HOME\Desktop\IRES"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt

sqlcmd -S localhost -E -C -i "Module 5\labs\statistical-analysis-data-visualization-python\01_setup_analysis_dataset.sql"
cd "$HOME\Desktop\IRES\Module 5\labs\statistical-analysis-data-visualization-python"
jupyter lab
```

In notebooks on Windows, set:

```python
ENV_FILE = ".env.windows"
```

## Deliverable

Complete `analytical_report_template.md` using tables, metrics, and images generated in `outputs/`.

## Quick Check

```sql
SELECT COUNT(*) AS ObservationRows FROM m5.DailyFinancialIndicators;
SELECT TOP 5 * FROM m5.DailyFinancialIndicators ORDER BY ObservationDate, InstitutionCode;
```
