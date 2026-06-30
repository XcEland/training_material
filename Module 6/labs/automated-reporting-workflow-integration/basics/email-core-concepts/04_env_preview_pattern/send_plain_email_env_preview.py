"""
Lesson 4: Email preview pattern using .env.

In this exercise:
- the sender, password, and recipient are read from .env
- the email is saved as a preview file before delivery
- the email is sent only when --send is provided
"""

from __future__ import annotations

import argparse
import os
import smtplib
from email.message import EmailMessage
from pathlib import Path

from dotenv import load_dotenv


lesson_folder = Path(__file__).resolve().parent
email_basics_folder = lesson_folder.parent
lab_folder = email_basics_folder.parent
output_folder = email_basics_folder / "outputs"


def env_value(name: str, fallback_name: str = "", default: str = "") -> str:
    """Read a value from .env, with an optional fallback name."""

    value = os.getenv(name)
    if not value and fallback_name:
        value = os.getenv(fallback_name)
    return (value or default).strip()


def create_message() -> EmailMessage:
    """Create a plain email message."""

    sender_email = env_value("REPORT_FROM_EMAIL", default=env_value("SMTP_USERNAME", "SPRING_MAIL_USERNAME"))
    receiver_email = env_value("REPORT_TO_EMAIL")

    if not receiver_email:
        raise ValueError("REPORT_TO_EMAIL is missing in .env.")

    msg = EmailMessage()
    msg["Subject"] = "Module 6 email basics - .env preview pattern"
    msg["From"] = sender_email
    msg["To"] = receiver_email
    msg.set_content(
        """
Hello,

This message uses the .env and preview pattern.

Regards,
Module 6 automated reporting lab
"""
    )
    return msg


def send_message(msg: EmailMessage) -> None:
    """Send the email using SMTP settings from .env."""

    smtp_host = env_value("SMTP_HOST", "SPRING_MAIL_HOST")
    smtp_port = int(env_value("SMTP_PORT", "SPRING_MAIL_PORT", "587"))
    smtp_username = env_value("SMTP_USERNAME", "SPRING_MAIL_USERNAME")
    smtp_password = env_value("SMTP_PASSWORD", "SPRING_MAIL_PASSWORD")
    use_tls = env_value("SMTP_USE_TLS", default="true").lower() in ("1", "true", "yes", "y")

    if not smtp_host:
        raise ValueError("SMTP_HOST or SPRING_MAIL_HOST is required in .env")

    with smtplib.SMTP(smtp_host, smtp_port, timeout=30) as smtp:
        if use_tls:
            smtp.starttls()
        if smtp_username:
            smtp.login(smtp_username, smtp_password)
        smtp.send_message(msg)


def main() -> None:
    parser = argparse.ArgumentParser(description="Preview or send an email using .env settings.")
    parser.add_argument("--send", action="store_true", help="Actually send the email.")
    args = parser.parse_args()

    load_dotenv(lab_folder / ".env")

    msg = create_message()

    output_folder.mkdir(exist_ok=True)
    preview_path = output_folder / "04_env_preview_pattern.eml"
    preview_path.write_text(msg.as_string(), encoding="utf-8")
    print(f"Preview created: {preview_path}")

    if args.send:
        send_message(msg)
        receiver_email = env_value("REPORT_TO_EMAIL")
        print(f"Email sent to {receiver_email}")
    else:
        print("Preview only. Add --send when you are ready to send.")


if __name__ == "__main__":
    main()
