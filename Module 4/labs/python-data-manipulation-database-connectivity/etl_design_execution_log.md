# Day 4 ETL Design and Execution Log

Document your Python ETL design and execution results in this log. Complete the design columns before writing code, then fill in the execution columns after running the notebook or script.

This log is the primary evidence artefact for the Day 4 exercise and will be referenced in the Day 10 Capstone.

## Student Details

- Student name:
- Pair/group:
- Run date:
- Notebook/script reviewed:
- Database/server used:

## ETL Design Plan

| Area | Design decision before coding | Reason |
| --- | --- | --- |
| Source table or file |  |  |
| Connection strategy: `pyodbc`, SQLAlchemy, or both |  |  |
| Columns to extract |  |  |
| Required non-null columns |  |  |
| Cleaning rules |  |  |
| Transformation rules |  |  |
| Validation checks |  |  |
| Target SQL table or output file |  |  |
| Error handling approach |  |  |
| Log output to capture |  |  |

## pyodbc vs SQLAlchemy: Connection Strategy Comparison

| Strategy | Best use | Why you chose or rejected it |
| --- | --- | --- |
| `pyodbc` direct connection | Testing SQL Server credentials, running stored procedures, cursor-based commands |  |
| SQLAlchemy engine | pandas `read_sql`, pandas `to_sql`, reusable ETL workflows, connection pooling |  |
| pandas with SQLAlchemy | Moving tabular data between SQL Server and DataFrames |  |

## Required Three-Step Validation Gate

Before any DataFrame is loaded back to SQL Server, record all three checks.

| Validation step | Code evidence | Result |
| --- | --- | --- |
| 1. Null check for non-nullable columns | `df[columns].isnull().sum()` |  |
| 2. Data type check against target schema | `df.dtypes` |  |
| 3. Row-count reconciliation | extracted rows vs clean rows + rejected rows |  |

## Execution Results

| Metric | Expected | Actual | Pass/Fail | Notes |
| --- | ---: | ---: | --- | --- |
| Extracted rows |  |  |  |  |
| Clean rows |  |  |  |  |
| Rejected rows |  |  |  |  |
| Clean + rejected rows |  |  |  |  |
| SQL clean table row count |  |  |  |  |
| SQL summary table row count |  |  |  |  |
| CSV output created |  |  |  |  |
| Excel output created |  |  |  |  |

## ETL Log Output

Paste the important notebook/script log lines here.

```text
VALIDATION GATE 1 - Null counts for non-nullable columns

VALIDATION GATE 2 - DataFrame dtypes compared with target schema notes

VALIDATION GATE 3 - Row-count reconciliation

VALIDATION GATE PASSED
```

## Findings and Fixes

| Issue found | Root cause | Fix applied | Preventive measure |
| --- | --- | --- | --- |
|  |  |  |  |
