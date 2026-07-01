"""Prepare and write a simple audit record from a Python job."""

import getpass
from datetime import datetime

import pandas as pd


def write_audit_log(engine, process_name, job_id, action, status, details, rows=None):
    """Append one audit row to audit.ProcessAuditLog when a SQL engine is available."""
    audit_df = pd.DataFrame(
        [
            {
                "ProcessName": process_name,
                "JobID": job_id,
                "ActionType": action,
                "Status": status,
                "RowsAffected": rows,
                "PerformedBy": getpass.getuser(),
                "PerformedAt": datetime.utcnow(),
                "Details": details,
            }
        ]
    )

    audit_df.to_sql(
        "ProcessAuditLog",
        engine,
        schema="audit",
        if_exists="append",
        index=False,
    )


def build_audit_row(process_name, job_id, action, status, details, rows=None):
    """Return one audit row for review before writing to SQL Server."""
    return pd.DataFrame(
        [
            {
                "ProcessName": process_name,
                "JobID": job_id,
                "ActionType": action,
                "Status": status,
                "RowsAffected": rows,
                "PerformedBy": getpass.getuser(),
                "PerformedAt": datetime.utcnow(),
                "Details": details,
            }
        ]
    )


job_id = "JOB-20260630-001"

audit_preview = build_audit_row(
    process_name="Monthly Reserve ETL",
    job_id=job_id,
    action="START",
    status="Started",
    details="Monthly ETL process started",
)

print(audit_preview)

# In the connected lab, call write_audit_log(engine, ...) after creating
# the environment-based engine from 12_env_credentials.py.
