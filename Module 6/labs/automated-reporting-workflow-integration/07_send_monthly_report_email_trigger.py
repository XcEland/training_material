"""
Triggered monthly report email lab.

This script is designed for Windows Task Scheduler or manual execution. It:
1. Runs the existing Jinja2 monthly reporting pipeline.
2. Loads/refreshed SQL Server tables when SQL Server is available.
3. Sends the generated report pack to the recipient configured in .env.

The target email for this lab is read from:
    REPORT_TO_EMAIL

Safe preview:
    python 07_send_monthly_report_email_trigger.py --dry-run

Real send:
    python 07_send_monthly_report_email_trigger.py
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import sys
import tempfile
from dataclasses import asdict
from pathlib import Path
from types import SimpleNamespace

from config.settings import DEFAULT_CONFIG, load_settings


LAB_DIR = Path(__file__).resolve().parent
PIPELINE_PATH = LAB_DIR / "06_monthly_reporting_pipeline.py"


def load_pipeline_runner():
    """Load the numbered pipeline file as a module."""
    spec = importlib.util.spec_from_file_location("module6_monthly_reporting_pipeline", PIPELINE_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load pipeline module from {PIPELINE_PATH}")
    module = importlib.util.module_from_spec(spec)
    sys.modules["module6_monthly_reporting_pipeline"] = module
    spec.loader.exec_module(module)
    return module.run_pipeline


def build_single_recipient_config(env_file: str, target_email: str) -> Path:
    """
    Create a temporary config that sends only to the target learner email.

    The normal config still keeps the broader stakeholder groups. This wrapper
    narrows the recipient list for the trigger lab without changing the shared
    course configuration file.
    """
    config = load_settings(DEFAULT_CONFIG, env_file)
    target_email = target_email or os.getenv("REPORT_TO_EMAIL", "")
    if not target_email:
        raise ValueError("REPORT_TO_EMAIL is required in .env or pass --to recipient@example.com")

    config_path_data = json.loads(Path(DEFAULT_CONFIG).read_text(encoding="utf-8"))
    config_path_data["stakeholder_groups"] = [
        {
            "group": "Triggered Monthly Reporting Lab Recipient",
            "recipients": [target_email],
        }
    ]

    temp_dir = Path(tempfile.gettempdir()) / "module6_triggered_email_lab"
    temp_dir.mkdir(parents=True, exist_ok=True)
    temp_config_path = temp_dir / "single_recipient_reporting_config.json"
    temp_config_path.write_text(json.dumps(config_path_data, indent=2), encoding="utf-8")

    # Ensure output folders exist before the reporting run writes artifacts.
    for key in ("outputs", "html", "email", "data"):
        config["paths"][key].mkdir(parents=True, exist_ok=True)
    return temp_config_path


def normalise_smtp_environment() -> None:
    """
    Support both Python SMTP variable names and Spring-style mail names.

    The email service reads SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD,
    and SMTP_USE_TLS. If a learner only has SPRING_MAIL_* values, map them here.
    """
    aliases = {
        "SMTP_HOST": "SPRING_MAIL_HOST",
        "SMTP_PORT": "SPRING_MAIL_PORT",
        "SMTP_USERNAME": "SPRING_MAIL_USERNAME",
        "SMTP_PASSWORD": "SPRING_MAIL_PASSWORD",
    }
    for target_name, source_name in aliases.items():
        if not os.getenv(target_name) and os.getenv(source_name):
            os.environ[target_name] = os.environ[source_name]


def run_triggered_email(args: argparse.Namespace) -> dict:
    # When --dry-run is not supplied, force the existing pipeline into send mode.
    if args.dry_run:
        os.environ["SEND_EMAILS"] = "false"
    else:
        os.environ["SEND_EMAILS"] = "true"

    temp_config = build_single_recipient_config(args.env, args.to)
    normalise_smtp_environment()
    run_pipeline = load_pipeline_runner()

    pipeline_args = SimpleNamespace(
        report_month=args.report_month,
        config=str(temp_config),
        env=args.env,
        reports=args.reports,
        email_template="executive_report_pack",
        refresh_data=True,
        skip_refresh_data=False,
        download_weo=args.download_weo,
        generate_pdf=args.generate_pdf,
        dry_run_email=args.dry_run,
    )

    result = run_pipeline(pipeline_args)
    return asdict(result)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate and email the monthly WEO report pack.")
    parser.add_argument("--to", help="Optional recipient override. Defaults to REPORT_TO_EMAIL from .env.")
    parser.add_argument("--report-month", default="2026-06", help="Report month in YYYY-MM format.")
    parser.add_argument("--env", default=".env", help="Environment file name inside the Module 6 lab folder.")
    parser.add_argument("--reports", help="Optional comma-separated report ids.")
    parser.add_argument("--download-weo", action="store_true", help="Download WEO workbook before reporting.")
    parser.add_argument("--generate-pdf", action="store_true", help="Generate PDFs if WeasyPrint is installed.")
    parser.add_argument("--dry-run", action="store_true", help="Create email preview instead of sending SMTP email.")
    return parser.parse_args()


def main() -> None:
    result = run_triggered_email(parse_args())
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
