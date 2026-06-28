"""Email preview and SMTP delivery service."""

from __future__ import annotations

import os
import smtplib
from email.message import EmailMessage
from pathlib import Path
from typing import Any

from reports.common import ReportArtifact
from services.template_renderer import build_environment


def all_recipients(config: dict[str, Any]) -> list[dict[str, str]]:
    recipients: list[dict[str, str]] = []
    for group in config["stakeholder_groups"]:
        for email in group["recipients"]:
            recipients.append({"group": group["group"], "email": email})
    return recipients


def send_or_preview_report_pack(
    report_month: str,
    artifacts: list[ReportArtifact],
    config: dict[str, Any],
    dry_run: bool,
    extra_context: dict[str, Any],
) -> tuple[str, Path]:
    recipients = all_recipients(config)
    env = build_environment(config["paths"]["templates"])
    template_config = selected_email_template(config)
    text_template = env.get_template(template_config["text_template"])
    html_template_name = template_config.get("html_template")
    html_template = env.get_template(html_template_name) if html_template_name else None

    preview_prefix = template_config.get("preview_prefix", "weo_report_pack_email")
    preview_path = config["paths"]["email"] / f"{preview_prefix}_{report_month}.txt"
    html_preview_path = config["paths"]["email"] / f"{preview_prefix}_{report_month}.html"
    preview_path.parent.mkdir(parents=True, exist_ok=True)

    context = {
        "report_month": report_month,
        "report_pack_title": config["report_pack_title"],
        "reports": artifacts,
        "recipients": recipients,
        "dry_run": dry_run,
        **extra_context,
    }
    body = text_template.render(
        **context,
    )
    html_body = html_template.render(**context) if html_template else None
    if html_body:
        html_preview_path.write_text(html_body, encoding="utf-8")
    preview_path.write_text(body, encoding="utf-8")

    if dry_run:
        return "DryRunPreviewCreated", preview_path

    smtp_host = os.getenv("SMTP_HOST", "")
    if not smtp_host:
        raise ValueError("SMTP_HOST is required when SEND_EMAILS=true")

    message = EmailMessage()
    message["From"] = os.getenv("REPORT_FROM_EMAIL", "reports@centralbank.example")
    message["To"] = ", ".join(recipient["email"] for recipient in recipients)
    message["Reply-To"] = os.getenv("REPORT_REPLY_TO", message["From"])
    message["Subject"] = f"{config['report_pack_title']} - {report_month}"
    message.set_content(body)
    if html_body:
        message.add_alternative(html_body, subtype="html")

    for artifact in artifacts:
        message.add_attachment(
            artifact.html_path.read_bytes(),
            maintype="text",
            subtype="html",
            filename=artifact.html_path.name,
        )
        if artifact.pdf_path and artifact.pdf_path.exists():
            message.add_attachment(
                artifact.pdf_path.read_bytes(),
                maintype="application",
                subtype="pdf",
                filename=artifact.pdf_path.name,
            )

    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_username = os.getenv("SMTP_USERNAME", "")
    smtp_password = os.getenv("SMTP_PASSWORD", "")
    use_tls = os.getenv("SMTP_USE_TLS", "true").lower() in ("yes", "true", "1")

    with smtplib.SMTP(smtp_host, smtp_port, timeout=30) as smtp:
        if use_tls:
            smtp.starttls()
        if smtp_username:
            smtp.login(smtp_username, smtp_password)
        smtp.send_message(message)

    return "Sent", preview_path


def selected_email_template(config: dict[str, Any]) -> dict[str, str]:
    email_templates = config.get("email_templates", {})
    selected_name = email_templates.get("selected", "executive_report_pack")
    available = email_templates.get("available", {})
    if selected_name not in available:
        raise ValueError(f"Unknown email template '{selected_name}'. Available templates: {list(available)}")
    return available[selected_name]
