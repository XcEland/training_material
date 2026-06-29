"""
Lesson 3: Send an HTML email using a Jinja2 template.

In this exercise:
- write the email design in a .html.j2 file
- pass Python data into that template
- send the rendered HTML as the email body
"""

import os
import smtplib
from email.message import EmailMessage
from pathlib import Path

from dotenv import load_dotenv
from jinja2 import Environment, FileSystemLoader


# Load the Module 6 .env file.
lab_folder = Path(__file__).resolve().parents[2]
load_dotenv(lab_folder / ".env")


# Sender email details from .env.
# The .env file may use either SMTP_* names or SPRING_MAIL_* names.
sender_email = (
    os.getenv("SMTP_USERNAME")
    or os.getenv("SPRING_MAIL_USERNAME")
)
sender_password = (
    os.getenv("SMTP_PASSWORD")
    or os.getenv("SPRING_MAIL_PASSWORD")
)
smtp_host = os.getenv("SMTP_HOST") or os.getenv("SPRING_MAIL_HOST") or "smtp.gmail.com"
smtp_port = int(os.getenv("SMTP_PORT") or os.getenv("SPRING_MAIL_PORT") or "587")

# Receiver email.
receiver_email = os.getenv("REPORT_TO_EMAIL")


if not sender_email or not sender_password:
    raise ValueError("Email username or password is missing in .env.")

if not receiver_email:
    raise ValueError("REPORT_TO_EMAIL is missing in .env.")


# This folder contains the Python file and the Jinja2 template.
lesson_folder = Path(__file__).resolve().parent


# Data that will be inserted into the Jinja2 template.
email_data = {
    "report_title": "Module 6 Monthly Reporting Update",
    "report_month": "2026-06",
    "recipient_name": "Findy",
    "summary_items": [
        "The monthly reporting workflow generated the HTML report pack.",
        "The email automation stage is ready for stakeholder distribution.",
        "Scheduler examples can trigger this same pattern automatically.",
    ],
    "status": "Ready for review",
}


# Load and render the Jinja2 template.
env = Environment(loader=FileSystemLoader(lesson_folder))
template = env.get_template("template_email.html.j2")
html_body = template.render(email_data)


# Create the email message.
msg = EmailMessage()
msg["Subject"] = "Module 6 email basics - Jinja2 HTML email"
msg["From"] = sender_email
msg["To"] = receiver_email


# Plain text fallback.
msg.set_content(
    """
Hello,

This email has an HTML version. If you see this text, your email client is
showing the plain text fallback.

Regards,
Module 6 automated reporting lab
"""
)


# HTML email body rendered by Jinja2.
msg.add_alternative(html_body, subtype="html")


# Send the email using Gmail SMTP.
with smtplib.SMTP(smtp_host, smtp_port) as smtp:
    smtp.starttls()
    smtp.login(sender_email, sender_password)
    smtp.send_message(msg)


print("Jinja2 HTML email sent successfully!")
