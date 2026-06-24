"""
Module 6 automated monthly reporting pipeline.

This script is intentionally explicit and heavily commented because it is a
teaching lab. It demonstrates:

1. Configuration management with environment variables and JSON config.
2. SQL Server extraction with generated fallback data.
3. Python processing with pandas.
4. Jinja2 report rendering.
5. Email automation with dry-run safety.
6. Execution logging and Phase 2 benchmark evaluation.
"""

from __future__ import annotations

import argparse
import json
import os
import smtplib
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from email.message import EmailMessage
from pathlib import Path
from typing import Any
from urllib.parse import quote_plus

import pandas as pd
from dotenv import load_dotenv
from jinja2 import Environment, FileSystemLoader, select_autoescape
from sqlalchemy import create_engine, text


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
TEMPLATE_DIR = LAB_DIR / "templates"
DEFAULT_CONFIG = LAB_DIR / "config" / "reporting_config.json"
RUN_LOG_PATH = OUTPUT_DIR / "monthly_report_run_log.jsonl"


@dataclass
class ReportRunResult:
    report_month: str
    status: str
    report_path: str
    email_status: str
    started_at: str
    completed_at: str
    message: str


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def load_environment(env_file: str) -> None:
    env_path = LAB_DIR / env_file
    if env_path.exists():
        load_dotenv(env_path)
    else:
        print(f"Environment file not found: {env_path}. Using process environment and defaults.")


def build_sqlalchemy_engine():
    """Build a SQLAlchemy engine from environment variables."""
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("DB_SERVER", "localhost,1433")
    database = os.getenv("DB_NAME", "TrainingDB")
    user = os.getenv("DB_USER", "sa")
    password = os.getenv("DB_PASSWORD", "StrongPassw0rd!2026")
    trusted = os.getenv("DB_TRUSTED", "no").lower() in ("yes", "true", "1")

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        "Encrypt=yes",
        "TrustServerCertificate=yes",
        "Connection Timeout=5",
    ]
    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={user}", f"PWD={password}"])

    connection_string = ";".join(parts) + ";"
    return create_engine(f"mssql+pyodbc:///?odbc_connect={quote_plus(connection_string)}")


def generated_monthly_data(report_month: str) -> pd.DataFrame:
    """Fallback data that mirrors the m6.MonthlyFinancialIndicators table."""
    month_start = f"{report_month}-01"
    rows = [
        ("CBL", "Central Bank Liquidity Desk", "Central Bank", "Maseru", 984_300_000, 337_800_000, 0.347, 0.225, 0.023, 38_160_000, 0),
        ("MCB", "Maseru Commercial Bank", "Commercial Bank", "Maseru", 668_500_000, 572_600_000, 0.271, 0.160, 0.059, 26_950_000, 0),
        ("LMB", "Leribe Microfinance Bank", "Microfinance", "Leribe", 211_900_000, 199_700_000, 0.214, 0.126, 0.095, 9_180_000, 1),
        ("QFB", "Quthing Finance Bank", "Commercial Bank", "Quthing", 306_800_000, 281_300_000, 0.238, 0.146, 0.078, 12_890_000, 0),
        ("BDB", "Butha-Buthe Development Bank", "Development Bank", "Butha-Buthe", 365_400_000, 330_500_000, 0.253, 0.153, 0.070, 15_320_000, 0),
        ("MFI", "Mafeteng Inclusion Finance", "Microfinance", "Mafeteng", 166_700_000, 162_600_000, 0.202, 0.116, 0.104, 7_440_000, 1),
    ]
    columns = [
        "InstitutionCode",
        "InstitutionName",
        "InstitutionType",
        "Region",
        "TotalDepositsLSL",
        "TotalLoansLSL",
        "LiquidityRatio",
        "CapitalAdequacyRatio",
        "NplRatio",
        "TransactionValueLSL",
        "StressFlag",
    ]
    data = pd.DataFrame(rows, columns=columns)
    data.insert(0, "ReportMonth", pd.to_datetime(month_start).date())
    return data


def extract_monthly_data(report_month: str) -> tuple[pd.DataFrame, str]:
    query = """
    SELECT
        ReportMonth,
        InstitutionCode,
        InstitutionName,
        InstitutionType,
        Region,
        TotalDepositsLSL,
        TotalLoansLSL,
        LiquidityRatio,
        CapitalAdequacyRatio,
        NplRatio,
        TransactionValueLSL,
        CAST(StressFlag AS INT) AS StressFlag
    FROM m6.MonthlyFinancialIndicators
    WHERE ReportMonth = :report_month
    ORDER BY InstitutionCode;
    """
    try:
        engine = build_sqlalchemy_engine()
        data = pd.read_sql(text(query), engine, params={"report_month": f"{report_month}-01"})
        if data.empty:
            raise ValueError(f"No SQL rows found for report month {report_month}")
        source = "SQL Server"
    except Exception as exc:
        print("Using generated fallback data. SQL extraction unavailable:", exc)
        data = generated_monthly_data(report_month)
        source = "generated fallback data"

    numeric_columns = [
        "TotalDepositsLSL",
        "TotalLoansLSL",
        "LiquidityRatio",
        "CapitalAdequacyRatio",
        "NplRatio",
        "TransactionValueLSL",
    ]
    data[numeric_columns] = data[numeric_columns].astype(float)
    data["StressFlag"] = data["StressFlag"].astype(int)
    return data, source


def calculate_metrics(data: pd.DataFrame, config: dict[str, Any]) -> dict[str, Any]:
    institution_count = int(len(data))
    stress_rows = int(data["StressFlag"].sum())
    stress_rate = float(stress_rows / institution_count) if institution_count else 0.0
    total_transaction_value = float(data["TransactionValueLSL"].sum())
    mean_liquidity = float(data["LiquidityRatio"].mean())
    mean_npl = float(data["NplRatio"].mean())

    thresholds = config["output_quality_thresholds"]
    benchmark_results = [
        {
            "benchmark": "Scheduling reliability logging present",
            "passed": True,
            "evidence": "Run log records start, completion, status, and message.",
        },
        {
            "benchmark": "Minimum institution rows",
            "passed": institution_count >= thresholds["minimum_institution_rows"],
            "evidence": f"{institution_count} rows processed.",
        },
        {
            "benchmark": "Stress rate within monitoring threshold",
            "passed": stress_rate <= thresholds["maximum_stress_rate"],
            "evidence": f"Stress rate {stress_rate:.2%}; threshold {thresholds['maximum_stress_rate']:.2%}.",
        },
        {
            "benchmark": "Stakeholder groups configured",
            "passed": len(config["stakeholder_groups"]) >= 1,
            "evidence": f"{len(config['stakeholder_groups'])} stakeholder groups configured.",
        },
    ]

    recommendation = (
        "Escalate stressed institutions for supervisory review and monitor liquidity deterioration."
        if stress_rows
        else "Continue routine monitoring; no stressed institutions were detected this month."
    )

    return {
        "institution_count": institution_count,
        "stress_rows": stress_rows,
        "stress_rate": stress_rate,
        "stress_rate_percent": f"{stress_rate:.2%}",
        "total_transaction_value": f"{total_transaction_value:,.2f}",
        "mean_liquidity": f"{mean_liquidity:.2%}",
        "mean_npl": f"{mean_npl:.2%}",
        "benchmark_results": benchmark_results,
        "recommendation": recommendation,
    }


def template_environment() -> Environment:
    return Environment(
        loader=FileSystemLoader(TEMPLATE_DIR),
        autoescape=select_autoescape(["html", "xml"]),
    )


def render_report(
    report_month: str,
    data: pd.DataFrame,
    metrics: dict[str, Any],
    config: dict[str, Any],
    source: str,
) -> Path:
    env = template_environment()
    template = env.get_template("executive_monthly_report.html.j2")
    report_path = OUTPUT_DIR / f"monthly_executive_report_{report_month}.html"
    context = {
        **metrics,
        "report_title": config["report_title"],
        "central_bank_name": config["central_bank_name"],
        "report_month": report_month,
        "generated_at": utc_now_iso(),
        "environment": os.getenv("REPORT_ENV", "development"),
        "data_source": source,
        "institution_rows": data.to_dict(orient="records"),
        "maximum_stress_rate": config["output_quality_thresholds"]["maximum_stress_rate"],
    }
    report_path.write_text(template.render(**context), encoding="utf-8")
    return report_path


def all_recipients(config: dict[str, Any]) -> list[dict[str, str]]:
    recipients: list[dict[str, str]] = []
    for group in config["stakeholder_groups"]:
        for email in group["recipients"]:
            recipients.append({"group": group["group"], "email": email})
    return recipients


def render_email_body(
    report_month: str,
    report_path: Path,
    metrics: dict[str, Any],
    config: dict[str, Any],
    dry_run: bool,
) -> str:
    env = template_environment()
    template = env.get_template("email_body.txt.j2")
    return template.render(
        **metrics,
        report_title=config["report_title"],
        report_month=report_month,
        report_path=str(report_path),
        dry_run=dry_run,
    )


def send_or_preview_email(
    report_month: str,
    report_path: Path,
    metrics: dict[str, Any],
    config: dict[str, Any],
    dry_run: bool,
) -> tuple[str, Path]:
    recipients = all_recipients(config)
    body = render_email_body(report_month, report_path, metrics, config, dry_run)
    preview_path = OUTPUT_DIR / f"monthly_email_preview_{report_month}.txt"
    preview_path.write_text(body, encoding="utf-8")

    if dry_run:
        return "DryRunPreviewCreated", preview_path

    message = EmailMessage()
    message["From"] = os.getenv("REPORT_FROM_EMAIL", "reports@centralbank.example")
    message["To"] = ", ".join(recipient["email"] for recipient in recipients)
    message["Reply-To"] = os.getenv("REPORT_REPLY_TO", message["From"])
    message["Subject"] = f"{config['report_title']} - {report_month}"
    message.set_content(body)
    message.add_attachment(
        report_path.read_bytes(),
        maintype="text",
        subtype="html",
        filename=report_path.name,
    )

    smtp_host = os.getenv("SMTP_HOST", "")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_username = os.getenv("SMTP_USERNAME", "")
    smtp_password = os.getenv("SMTP_PASSWORD", "")
    use_tls = os.getenv("SMTP_USE_TLS", "true").lower() in ("yes", "true", "1")

    if not smtp_host:
        raise ValueError("SMTP_HOST is required when SEND_EMAILS=true")

    with smtplib.SMTP(smtp_host, smtp_port, timeout=30) as smtp:
        if use_tls:
            smtp.starttls()
        if smtp_username:
            smtp.login(smtp_username, smtp_password)
        smtp.send_message(message)

    return "Sent", preview_path


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def append_run_log(result: ReportRunResult, extra: dict[str, Any]) -> None:
    RUN_LOG_PATH.parent.mkdir(exist_ok=True)
    payload = {**result.__dict__, **extra}
    with RUN_LOG_PATH.open("a", encoding="utf-8") as file:
        file.write(json.dumps(payload) + "\n")


def try_log_to_sql(
    report_month: str,
    status: str,
    report_path: Path,
    email_status: str,
    message: str,
    recipients: list[dict[str, str]],
) -> None:
    try:
        engine = build_sqlalchemy_engine()
        with engine.begin() as conn:
            run_id = conn.execute(
                text(
                    """
                    INSERT INTO m6.MonthlyReportRunLog
                        (CompletedAt, ReportMonth, Status, OutputPath, EmailStatus, Message)
                    OUTPUT inserted.RunID
                    VALUES
                        (SYSUTCDATETIME(), :report_month, :status, :output_path, :email_status, :message);
                    """
                ),
                {
                    "report_month": f"{report_month}-01",
                    "status": status,
                    "output_path": str(report_path),
                    "email_status": email_status,
                    "message": message,
                },
            ).scalar_one()

            for recipient in recipients:
                conn.execute(
                    text(
                        """
                        INSERT INTO m6.ReportDistributionAudit
                            (RunID, ReportMonth, RecipientEmail, RecipientGroup, DeliveryStatus)
                        VALUES
                            (:run_id, :report_month, :email, :group_name, :delivery_status);
                        """
                    ),
                    {
                        "run_id": run_id,
                        "report_month": f"{report_month}-01",
                        "email": recipient["email"],
                        "group_name": recipient["group"],
                        "delivery_status": email_status,
                    },
                )
        print("SQL run log updated.")
    except Exception as exc:
        print("SQL run log skipped:", exc)


def run_pipeline(args: argparse.Namespace) -> ReportRunResult:
    OUTPUT_DIR.mkdir(exist_ok=True)
    started_at = utc_now_iso()
    started_seconds = time.perf_counter()
    load_environment(args.env)
    config = load_json(Path(args.config))
    report_month = args.report_month or config["default_report_month"]

    dry_run = args.dry_run_email or os.getenv("SEND_EMAILS", "false").lower() not in ("yes", "true", "1")

    data, source = extract_monthly_data(report_month)
    metrics = calculate_metrics(data, config)
    report_path = render_report(report_month, data, metrics, config, source)
    email_status, email_preview_path = send_or_preview_email(report_month, report_path, metrics, config, dry_run)

    pipeline_seconds = round(time.perf_counter() - started_seconds, 2)
    evaluation = {
        "report_month": report_month,
        "data_source": source,
        "pipeline_seconds": pipeline_seconds,
        "email_status": email_status,
        "benchmarks": metrics["benchmark_results"],
        "report_path": str(report_path),
        "email_preview_path": str(email_preview_path),
    }
    write_json(OUTPUT_DIR / f"monthly_metrics_{report_month}.json", {**metrics, "data_source": source})
    write_json(OUTPUT_DIR / f"phase2_pipeline_evaluation_{report_month}.json", evaluation)

    completed_at = utc_now_iso()
    result = ReportRunResult(
        report_month=report_month,
        status="Succeeded",
        report_path=str(report_path),
        email_status=email_status,
        started_at=started_at,
        completed_at=completed_at,
        message=f"Completed in {pipeline_seconds} seconds using {source}.",
    )
    append_run_log(result, {"evaluation_path": str(OUTPUT_DIR / f"phase2_pipeline_evaluation_{report_month}.json")})
    try_log_to_sql(report_month, result.status, report_path, email_status, result.message, all_recipients(config))
    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the Module 6 monthly reporting pipeline.")
    parser.add_argument("--report-month", help="Report month in YYYY-MM format. Example: 2026-06")
    parser.add_argument("--config", default=str(DEFAULT_CONFIG), help="Path to JSON reporting config.")
    parser.add_argument("--env", default=".env", help="Environment file name inside the lab folder.")
    parser.add_argument("--dry-run-email", action="store_true", help="Force email preview instead of SMTP delivery.")
    return parser.parse_args()


def main() -> None:
    try:
        result = run_pipeline(parse_args())
        print(json.dumps(result.__dict__, indent=2))
    except Exception as exc:
        failed = ReportRunResult(
            report_month="unknown",
            status="Failed",
            report_path="",
            email_status="NotAttempted",
            started_at=utc_now_iso(),
            completed_at=utc_now_iso(),
            message=str(exc),
        )
        append_run_log(failed, {})
        raise


if __name__ == "__main__":
    main()
