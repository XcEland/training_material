# Statistical Analysis and Data Visualization with Python

This Module 5 lab uses Python Jupyter notebooks to move students from beginner statistical-analysis concepts to an integrated analytical report. Each notebook includes its own package-install cell, so it can run in a local virtual environment, VS Code, JupyterLab, or Google Colab.

Run `.ipynb` files with a Python 3 kernel. Do not run notebook cells in SQL Server, DBeaver, Azure Data Studio SQL query mode, or `sqlcmd`. If you see errors such as `Incorrect syntax near '%'`, SQL Server is trying to execute Python notebook code.

The beginner notebooks `05`, `06`, and `07` do not require a database connection. They load `data/beginner_financial_indicators.csv` when it is present, and create a small fallback dataset inside the notebook when it is not present, which makes them suitable for Google Colab.

The WEO notebooks `08`, `09`, and `10` use the Excel workbook from Module 4:

```text
Module 4/labs/python-data-manipulation-database-connectivity/data/WEOApr2026all.xlsx
```

These notebooks create analysis-ready DataFrames from multiple sheets, including `Countries`, `Country Groups`, `Commodity Prices`, and `Country Group Composition`.

In Google Colab, the WEO notebooks also check:

```text
/content/WEOApr2026all.xlsx
```

The integrated notebooks `01`, `02`, `03`, and `04` try to extract data from SQL Server first. If SQL Server is not available, they generate the same style of financial indicator data inside the notebook so the analysis, visualization, machine learning, and time-series exercises still run.

## Learning Order

1. Prepare the SQL Server analysis dataset when SQL Server is available.
2. Start with `05_beginner_scipy_statistics.ipynb` for beginner descriptive statistics, correlations, z-scores, confidence intervals, and hypothesis tests.
3. Run `06_beginner_matplotlib_seaborn_visualization.ipynb` for simple chart construction: line, scatter, histogram, box plot, bar chart, horizontal bar chart, heatmap, and confusion matrix.
4. Run `07_beginner_ml_model_pipelines.ipynb` for simple classification, regression, and time-series style prediction pipelines.
5. Run `08_weo_scipy_statistics.ipynb` for WEO Excel loading, sheet preparation, SciPy statistics, correlations, outliers, and group hypothesis testing.
6. Run `09_weo_visualization_eda.ipynb` for WEO EDA charts across GDP growth, inflation, economic groups, and commodity prices.
7. Run `10_weo_ml_prediction.ipynb` for a next-year GDP growth prediction model using WEO macroeconomic indicators.
8. Continue to the existing SciPy, visualization, machine learning, and time-series notebooks for the integrated Module 5 workflow.
9. Create a report summary and evaluate the Phase 1 pipeline benchmarks.

New beginner notebooks are added without deleting the existing labs. The existing notebooks remain the integrated reporting workflow.

## Files

```text
Module 5/labs/statistical-analysis-data-visualization-python/
├── README.md
├── .env
├── .env.windows
├── 01_setup_analysis_dataset.sql
├── analysis_utils.py
├── data/
│   └── beginner_financial_indicators.csv
├── 05_beginner_scipy_statistics.ipynb
├── 06_beginner_matplotlib_seaborn_visualization.ipynb
├── 07_beginner_ml_model_pipelines.ipynb
├── 08_weo_scipy_statistics.ipynb
├── 09_weo_visualization_eda.ipynb
├── 10_weo_ml_prediction.ipynb
├── 01_statistics_scipy.ipynb
├── 02_visualization_matplotlib_seaborn.ipynb
├── 03_machine_learning_sklearn.ipynb
├── 04_time_series_and_report.ipynb
├── analytical_report_template.md
└── outputs/
```

## Notebook Coverage

| Notebook | Session focus | Module 5 outcome |
| --- | --- | --- |
| `05_beginner_scipy_statistics.ipynb` | Beginner SciPy statistics with commented examples | Build statistical intuition before advanced analysis |
| `06_beginner_matplotlib_seaborn_visualization.ipynb` | Beginner charting with line, scatter, histogram, box, bar, heatmap, and confusion matrix charts | Understand how common visualizations are drawn and interpreted |
| `07_beginner_ml_model_pipelines.ipynb` | Beginner ML pipelines for classification, regression, and simple time-series style prediction | Learn the basic model workflow from data loading to saved model testing |
| `08_weo_scipy_statistics.ipynb` | WEO Excel workbook loading, multi-sheet DataFrame preparation, SciPy statistics, confidence intervals, correlations, outliers, and t-tests | Apply statistics to real macroeconomic workbook data |
| `09_weo_visualization_eda.ipynb` | WEO EDA charts for GDP growth, inflation, country groups, and commodity prices | Build scenario-based visual analysis from multiple workbook sheets |
| `10_weo_ml_prediction.ipynb` | Predict next-year GDP growth from WEO macro indicators using linear regression and random forest models | Practice a realistic predictive modeling workflow from Excel data |
| `01_statistics_scipy.ipynb` | SciPy descriptive statistics, correlation, and hypothesis testing | Apply statistical functions to financial datasets |
| `02_visualization_matplotlib_seaborn.ipynb` | Matplotlib and Seaborn charts with interpretation checks | Evaluate whether charts represent distributions and trends accurately |
| `03_machine_learning_sklearn.ipynb` | Scikit-learn classification, confusion matrix, accuracy, precision, and recall | Assess predictive reliability of business-data patterns |
| `04_time_series_and_report.ipynb` | Time-series decomposition, simple forecast, report summary, SQL log, and benchmark evaluation | Integrate T-SQL extraction, Python analysis, visualisation, and pipeline benchmark review |

## Local Setup

From the repository root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
pip install notebook jupyterlab scipy matplotlib seaborn scikit-learn
```

If SQL Server is available, create the Module 5 dataset:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 5/labs/statistical-analysis-data-visualization-python/01_setup_analysis_dataset.sql"
```

Run notebooks:

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 5/labs/statistical-analysis-data-visualization-python"
jupyter lab
```

## Windows Setup

If using SQL Server Express, change `.env.windows`:

```env
DB_SERVER=localhost\SQLEXPRESS
```

From PowerShell:

```powershell
cd "$HOME\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt
pip install notebook jupyterlab scipy matplotlib seaborn scikit-learn

sqlcmd -S localhost -E -C -i "Module 5\labs\statistical-analysis-data-visualization-python\01_setup_analysis_dataset.sql"
cd "$HOME\Desktop\Trainingcred Institute\Module 5\labs\statistical-analysis-data-visualization-python"
jupyter lab
```

In notebooks on Windows, set:

```python
ENV_FILE = ".env.windows"
```

## Database Connection

Database connection settings are used by the integrated notebooks `01` to `04`, not by the beginner notebooks `05` to `07`.

Configuration files:

```text
.env
.env.windows
```

Connection helper code:

```text
analysis_utils.py
```

The helper functions are:

```python
load_settings()
get_pyodbc_connection()
get_sqlalchemy_engine()
load_indicator_data()
```

## Google Colab Setup

1. Upload a notebook to Colab.
2. Run the first install cell.
3. Continue with the notebook.
4. For beginner notebooks `05`, `06`, and `07`, no SQL Server connection is needed. If the CSV file is not uploaded with the notebook, the notebook creates fallback data.
5. For WEO notebooks `08`, `09`, and `10`, upload `WEOApr2026all.xlsx` if Colab cannot see the local Module 4 path. The notebooks will look for `/content/WEOApr2026all.xlsx`.
6. For integrated notebooks `01`, `02`, `03`, and `04`, if SQL Server is not reachable, the notebook uses generated financial indicator data.
7. Download the generated `outputs/` files or copy the report text into `analytical_report_template.md`.

No SQL Server connection is required for the beginner statistical, visualization, or machine-learning learning activities.

## Expected Outputs

The notebooks generate outputs such as:

```text
outputs/statistical_summary.csv
outputs/correlation_matrix.csv
outputs/institution_type_summary.csv
outputs/beginner_scipy_summary.csv
outputs/beginner_scipy_institution_summary.csv
outputs/beginner_line_chart.png
outputs/beginner_scatter_plot.png
outputs/beginner_histogram.png
outputs/beginner_boxplot_outliers.png
outputs/beginner_vertical_bar.png
outputs/beginner_horizontal_bar.png
outputs/beginner_correlation_heatmap.png
outputs/beginner_confusion_matrix_heatmap.png
outputs/beginner_visual_dashboard.png
outputs/beginner_ml_confusion_matrix.png
outputs/beginner_stress_classifier.joblib
outputs/beginner_profit_regression.joblib
outputs/beginner_liquidity_time_model.joblib
outputs/beginner_ml_model_metrics.csv
outputs/weo_scipy_2026_summary.csv
outputs/weo_scipy_growth_outliers.csv
outputs/weo_group_gdp_growth_trend.png
outputs/weo_top_bottom_growth_bar.png
outputs/weo_inflation_vs_growth_scatter.png
outputs/weo_inflation_histogram.png
outputs/weo_growth_boxplot_by_group.png
outputs/weo_indicator_correlation_heatmap.png
outputs/weo_commodity_price_trends.png
outputs/weo_eda_dashboard.png
outputs/weo_ml_model_error_comparison.png
outputs/weo_ml_actual_vs_predicted.png
outputs/weo_ml_feature_importance.png
outputs/weo_next_year_gdp_growth_model.joblib
outputs/weo_ml_model_metrics.csv
outputs/weo_ml_prediction_review.csv
outputs/weo_ml_feature_importance.csv
outputs/liquidity_trend.png
outputs/npl_distribution_by_type.png
outputs/correlation_heatmap.png
outputs/stress_classifier_confusion_matrix.png
outputs/stress_model_coefficients.csv
outputs/model_metrics.csv
outputs/liquidity_decomposition.png
outputs/liquidity_decomposition_components.csv
outputs/liquidity_forecast.csv
outputs/liquidity_forecast.png
outputs/phase1_pipeline_benchmarks.csv
outputs/module5_report_summary.md
```

## Deliverable

Complete `analytical_report_template.md` using tables, metrics, charts, benchmark results, and narrative generated by the notebooks.

## Quick SQL Check

```sql
SELECT COUNT(*) AS ObservationRows FROM m5.DailyFinancialIndicators;
SELECT TOP 5 * FROM m5.DailyFinancialIndicators ORDER BY ObservationDate, InstitutionCode;
SELECT TOP 5 * FROM m5.AnalysisReportRun ORDER BY ReportRunID DESC;
```
