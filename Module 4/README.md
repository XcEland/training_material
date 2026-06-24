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
02_pandas_cleaning_transformation_workflow.ipynb
03_numpy_quantitative_validation.ipynb
04_file_io_etl_load_back_to_sql.ipynb
```

The lab uses `TrainingDB` and creates objects under the `m4` schema when SQL Server is available. The notebooks also include CSV and built-in fallback data so students can run the pandas, NumPy, and file I/O sections in another IDE or Google Colab.
