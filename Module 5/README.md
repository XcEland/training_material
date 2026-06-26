# Module 5: Statistical Analysis and Data Visualization with Python

Module 5 turns SQL Server extracts into statistical analysis, visualizations, simple predictive models, time-series analysis, and an analytical report. The lab is notebook-first and can also run in Google Colab using generated fallback data when SQL Server is unavailable.

## Lab

```text
Module 5/labs/statistical-analysis-data-visualization-python/
```

The lab covers:

- descriptive statistics, hypothesis testing, and correlation analysis with SciPy
- Matplotlib and Seaborn charts for analytical reporting and visual interpretation
- Scikit-learn fundamentals for classification, confusion matrices, and reliability checks
- WEO Excel workbook analysis for macroeconomic statistics, EDA, commodity trends, and GDP growth prediction
- time series decomposition, trend analysis, residual review, and simple forecasting
- a final report that combines SQL extraction, Python analysis, professional visualization, and Phase 1 benchmark evaluation

The primary notebooks are:

```text
05_beginner_scipy_statistics.ipynb
06_beginner_matplotlib_seaborn_visualization.ipynb
07_beginner_ml_model_pipelines.ipynb
08_weo_scipy_statistics.ipynb
09_weo_visualization_eda.ipynb
10_weo_ml_prediction.ipynb
01_statistics_scipy.ipynb
02_visualization_matplotlib_seaborn.ipynb
03_machine_learning_sklearn.ipynb
04_time_series_and_report.ipynb
```

The beginner notebooks introduce SciPy, charting, and Scikit-learn with a small CSV dataset and heavily commented code before learners move into the existing integrated Module 5 notebooks.

The WEO notebooks use the Module 4 Excel workbook to teach macroeconomic data preparation from multiple sheets, SciPy statistics, Matplotlib/Seaborn EDA, commodity trend charts, and a simple next-year GDP growth prediction model.

Beginner dataset:

```text
labs/statistical-analysis-data-visualization-python/data/beginner_financial_indicators.csv
```

WEO workbook:

```text
../Module 4/labs/python-data-manipulation-database-connectivity/data/WEOApr2026all.xlsx
```

The lab uses `TrainingDB` and creates objects under the `m5` schema when SQL Server is available.
