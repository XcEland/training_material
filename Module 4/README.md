# Module 4: Python Data Manipulation and Database Connectivity

Module 4 connects SQL Server data workflows to Python ETL tooling through Jupyter notebooks.

## Lab

```text
Module 4/labs/python-data-manipulation-database-connectivity/
```

The lab covers:

- SQL Server connectivity with `pyodbc`, SQLAlchemy, and pandas
- pandas DataFrame extraction, cleaning, transformation, and aggregation
- NumPy calculations and validation checks
- CSV and Excel file output
- Loading transformed results back to SQL Server

The primary exercises are notebooks:

```text
01_database_connectivity_pyodbc_sqlalchemy_pandas.ipynb
05_pandas_weo_transformation_basics.ipynb
06_numpy_weo_array_validation_basics.ipynb
02_pandas_cleaning_transformation_workflow.ipynb
03_numpy_quantitative_validation.ipynb
04_file_io_etl_load_back_to_sql.ipynb
```

The WEO pandas and NumPy notebooks appear early because they teach DataFrame and array basics with the IMF WEO Excel dataset at `data/WEOApr2026all.xlsx`. Existing transaction-based notebooks remain available for ETL, validation, and load-back practice.

The lab uses `TrainingDB` and creates objects under the `m4` schema when SQL Server is available. The notebooks also include CSV and built-in fallback data so the pandas, NumPy, and file I/O sections can run in another IDE or Google Colab.
