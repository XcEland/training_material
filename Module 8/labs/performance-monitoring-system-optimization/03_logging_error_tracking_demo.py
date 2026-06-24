"""
Python logging framework and error tracking demo.

Production standard used in this lab:
- DEBUG: detailed diagnostics during development
- INFO: successful stage completion
- WARNING: data quality anomalies that do not halt execution
- ERROR: caught exceptions that are handled
- CRITICAL: failures that halt the pipeline

The script writes to a rotating file handler. It also attempts optional SQL
logging to m8.PythonWorkflowExecutionLog when SQL Server is available.
"""

from __future__ import annotations

import argparse
import logging
import logging.handlers
import time
from pathlib import Path

from sqlalchemy import text

from db_utils import get_sqlalchemy_engine


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
LOG_PATH = OUTPUT_DIR / "python_workflow.log"


def configure_logging(level: str = "INFO") -> logging.Logger:
    OUTPUT_DIR.mkdir(exist_ok=True)
    logger = logging.getLogger("module8.workflow")
    logger.setLevel(getattr(logging, level.upper(), logging.INFO))
    logger.handlers.clear()

    formatter = logging.Formatter(
        "%(asctime)s | %(levelname)s | %(name)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    file_handler = logging.handlers.RotatingFileHandler(
        LOG_PATH,
        maxBytes=100_000,
        backupCount=3,
        encoding="utf-8",
    )
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    return logger


def try_log_to_database(env_file: str, severity: str, stage: str, message: str, duration_ms: int | None = None) -> None:
    """Optional database logging for audit trails."""
    try:
        engine = get_sqlalchemy_engine(env_file)
        with engine.begin() as conn:
            conn.execute(
                text(
                    """
                    INSERT INTO m8.PythonWorkflowExecutionLog
                        (WorkflowName, Severity, StageName, Message, DurationMs, RowsProcessed)
                    VALUES
                        ('Module8LoggingDemo', :severity, :stage, :message, :duration_ms, NULL);
                    """
                ),
                {
                    "severity": severity,
                    "stage": stage,
                    "message": message,
                    "duration_ms": duration_ms,
                },
            )
    except Exception as exc:
        # Database logging failure should not hide the original workflow event.
        logging.getLogger("module8.workflow").warning("Database logging skipped: %s", exc)


def run_workflow(env_file: str, force_failure: bool = False) -> None:
    logger = configure_logging()
    started = time.perf_counter()
    logger.info("Workflow started")
    try_log_to_database(env_file, "INFO", "start", "Workflow started")

    try:
        logger.debug("Loading source data")
        rows = [
            {"id": 1, "amount": 100.0},
            {"id": 2, "amount": None},
            {"id": 3, "amount": 250.0},
        ]
        logger.info("Source data loaded with %s rows", len(rows))

        missing_amount_rows = [row for row in rows if row["amount"] is None]
        if missing_amount_rows:
            logger.warning("Data quality anomaly: %s rows have missing amount", len(missing_amount_rows))
            try_log_to_database(env_file, "WARNING", "validation", "Rows with missing amount detected")

        clean_rows = [row for row in rows if row["amount"] is not None]
        if force_failure:
            raise RuntimeError("Forced failure for CRITICAL logging demonstration")

        total_amount = sum(row["amount"] for row in clean_rows)
        duration_ms = int((time.perf_counter() - started) * 1000)
        logger.info("Workflow completed successfully; total_amount=%s duration_ms=%s", total_amount, duration_ms)
        try_log_to_database(env_file, "INFO", "complete", "Workflow completed successfully", duration_ms)

    except ValueError as exc:
        logger.error("Handled validation error: %s", exc)
        try_log_to_database(env_file, "ERROR", "validation", str(exc))
    except Exception as exc:
        logger.critical("Workflow halted: %s", exc)
        try_log_to_database(env_file, "CRITICAL", "halt", str(exc))
        raise


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Module 8 logging demo.")
    parser.add_argument("--env", default=".env")
    parser.add_argument("--force-failure", action="store_true")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run_workflow(args.env, args.force_failure)
