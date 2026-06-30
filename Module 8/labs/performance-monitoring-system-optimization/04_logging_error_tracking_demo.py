"""
Python logging and error tracking demo.

Run:
    python3 04_logging_error_tracking_demo.py
    python3 04_logging_error_tracking_demo.py --force-failure

The script writes:
- file logs to outputs/python_workflow.log
- optional SQL logs to dbo.PythonWorkflowLog when .env is configured
"""

from __future__ import annotations

import argparse
import logging
from logging.handlers import RotatingFileHandler
import os
import time
from pathlib import Path

from sqlalchemy import text

from db_utils import can_reach_sql_server, get_sqlalchemy_engine, load_environment
from monitoring_data_sources import build_workflow_observations


OUTPUT_DIR = Path(__file__).resolve().parent / "outputs"
LOG_PATH = OUTPUT_DIR / "python_workflow.log"


def configure_logger(level: str) -> logging.Logger:
    """Create a small rotating file logger."""
    OUTPUT_DIR.mkdir(exist_ok=True)

    logger = logging.getLogger("etl_monitor")
    logger.setLevel(getattr(logging, level.upper(), logging.INFO))
    logger.handlers.clear()

    handler = RotatingFileHandler(LOG_PATH, maxBytes=100_000, backupCount=3, encoding="utf-8")
    handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
    logger.addHandler(handler)

    console = logging.StreamHandler()
    console.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
    logger.addHandler(console)
    return logger


def write_log_to_sql(
    env_file: str,
    step_name: str,
    severity: str,
    message: str,
    rows_processed: int | None = None,
    duration_seconds: float | None = None,
) -> None:
    """Write one log row to SQL Server when database settings are available."""
    load_environment(env_file)
    trusted = os.getenv("DB_TRUSTED", "no").lower() in ("yes", "true", "1")
    if not trusted and not os.getenv("DB_PASSWORD"):
        return
    if not can_reach_sql_server():
        return

    engine = get_sqlalchemy_engine(env_file)
    with engine.begin() as conn:
        conn.execute(
            text(
                """
                INSERT INTO dbo.PythonWorkflowLog
                    (JobID, WorkflowName, StepName, Severity, Message, RowsProcessed, DurationSeconds)
                VALUES
                    (:job_id, :workflow_name, :step_name, :severity, :message, :rows_processed, :duration_seconds);
                """
            ),
            {
                "job_id": "M8-PY-LOG-001",
                "workflow_name": "Module 8 Python Logging Demo",
                "step_name": step_name,
                "severity": severity,
                "message": message,
                "rows_processed": rows_processed,
                "duration_seconds": duration_seconds,
            },
        )


def safe_sql_log(logger: logging.Logger, env_file: str, *args) -> None:
    """Keep the workflow running even if SQL logging is not available."""
    try:
        write_log_to_sql(env_file, *args)
    except Exception as exc:
        logger.warning("SQL logging skipped: %s", exc)


def run_workflow(env_file: str, level: str, force_failure: bool) -> None:
    logger = configure_logger(level)
    start = time.perf_counter()

    logger.info("Workflow started")
    safe_sql_log(logger, env_file, "Start", "INFO", "Workflow started")

    try:
        rows = build_workflow_observations()
        rows_processed = sum(row["records_processed"] for row in rows)

        logger.info("Loaded %s workflow rows", len(rows))

        issue_count = sum(row["quality_issue_count"] for row in rows)
        if issue_count > 0:
            logger.warning("Data quality warning detected: %s issues", issue_count)

        if force_failure:
            raise RuntimeError("Forced failure for logging practice")

        duration = round(time.perf_counter() - start, 2)
        logger.info("Workflow completed in %.2f seconds", duration)
        safe_sql_log(logger, env_file, "Complete", "INFO", "Workflow completed", rows_processed, duration)

    except Exception as exc:
        duration = round(time.perf_counter() - start, 2)
        logger.error("An error occurred during processing: %s", exc)
        safe_sql_log(logger, env_file, "Error", "ERROR", str(exc), None, duration)
        raise


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the Module 8 logging demo.")
    parser.add_argument("--env", default=".env")
    parser.add_argument("--level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR"])
    parser.add_argument("--force-failure", action="store_true")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run_workflow(args.env, args.level, args.force_failure)
