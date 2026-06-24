# ETL Peer Review Checklist

Use this during the Module 4 collaborative troubleshooting session.

## Script Reviewed

- Reviewer:
- Author:
- Script name:
- Run date:

## Connectivity

- Uses environment variables:
- Connects successfully:
- Handles connection errors:
- Uses the expected database:
- Explains when to use `pyodbc` direct connections:
- Explains when to use SQLAlchemy with pandas:

## Extraction

- Source table:
- Extracted row count:
- Query is readable:
- Query selects only required columns:

## Transformation

- Date parsing handled:
- Currency codes normalised:
- Amounts converted to numeric:
- Null values handled:
- Rejected rows identified:

## Validation

- Row-count reconciliation:
- Required non-nullable columns checked with `df.isnull().sum()`:
- DataFrame types checked with `df.dtypes`:
- NumPy total check:
- Summary totals match detail totals:
- Validation gate printed in notebook/script log output:

## File Outputs

- CSV output created:
- Excel output created:
- File names are clear:

## SQL Load

- Clean table loaded:
- Summary table loaded:
- ETL run log updated:
- Final SQL row counts verified:

## Evidence Artefact

- `etl_design_execution_log.md` completed before coding:
- Execution results added after running:
- Log output pasted into the evidence artefact:
- Evidence can support Day 10 Capstone review:

## Findings

- Main issue found:
- Fix applied:
- Preventive measure:
