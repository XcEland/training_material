"""
Lesson 1: Send a simple plain email.

In this exercise:
- read sender details from .env
- create a plain email message
- connect to Gmail SMTP
- send the message
"""

import os
import smtplib
from email.message import EmailMessage
from pathlib import Path

from dotenv import load_dotenv


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


# Create the email message.
msg = EmailMessage()
msg["Subject"] = "Module 6 email basics - plain message"
msg["From"] = sender_email
msg["To"] = receiver_email


# Plain email body.
msg.set_content(
    """
Hello,

This is a plain email sent from Python.

Regards,
Module 6 automated reporting lab
"""
)


# Send the email using Gmail SMTP.
with smtplib.SMTP(smtp_host, smtp_port) as smtp:
    smtp.starttls()
    smtp.login(sender_email, sender_password)
    smtp.send_message(msg)


print("Email sent successfully!")
