"""
Lesson 2: Send a simple email with an attachment.

In this exercise:
- create a plain email message
- read a file from disk
- attach it to the email before sending
"""

import mimetypes
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

# The file we want to attach.
# This finds the main course folder, then selects a PDF from Course/.
course_root = Path(__file__).resolve().parents[5]
attachment_path = course_root / "Course" / "Transact-SQL training_program.pdf"


if not sender_email or not sender_password:
    raise ValueError("Email username or password is missing in .env.")

if not receiver_email:
    raise ValueError("REPORT_TO_EMAIL is missing in .env.")

if not attachment_path.exists():
    raise FileNotFoundError(f"Attachment not found: {attachment_path}")


# Create the email message.
msg = EmailMessage()
msg["Subject"] = "Module 6 email basics - message with attachment"
msg["From"] = sender_email
msg["To"] = receiver_email


# Plain email body.
msg.set_content(
    f"""
Hello,

This email includes a course PDF attachment.

Attached file: {attachment_path.name}

Regards,
Module 6 automated reporting lab
"""
)


# Work out the attachment type. A PDF becomes application/pdf.
content_type, _ = mimetypes.guess_type(attachment_path)
if content_type is None:
    content_type = "application/octet-stream"

main_type, sub_type = content_type.split("/", 1)


# Attach the file to the email.
with open(attachment_path, "rb") as file:
    msg.add_attachment(
        file.read(),
        maintype=main_type,
        subtype=sub_type,
        filename=attachment_path.name,
    )


# Send the email using Gmail SMTP.
with smtplib.SMTP(smtp_host, smtp_port) as smtp:
    smtp.starttls()
    smtp.login(sender_email, sender_password)
    smtp.send_message(msg)


print("Email with attachment sent successfully!")
