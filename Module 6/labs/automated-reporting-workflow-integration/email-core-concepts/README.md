# Email Core Concepts

This folder teaches email automation one step at a time.

The examples send to the address configured in `.env`:

```text
REPORT_TO_EMAIL=findyandx@gmail.com
```

Lessons 1-3 use very simple beginner code with sender variables near the top of
each Python file. Those variables are loaded from the Module 6 `.env` file.

Lesson 4 introduces preview mode and environment-based configuration.

## Lesson Order

1. `01_plain_message/` - send a simple plain text email.
2. `02_message_with_attachment/` - send a plain text email with a course PDF attachment.
3. `03_jinja_html_email/` - render an HTML email using a Jinja2 template.
4. `04_env_preview_pattern/` - use `.env`, preview mode, and `--send`.

## Beginner Lessons

From this folder:

```bash
../../../.venv/bin/python 01_plain_message/send_plain_email.py
../../../.venv/bin/python 02_message_with_attachment/send_email_with_attachment.py
../../../.venv/bin/python 03_jinja_html_email/send_jinja_email.py
```

These scripts send immediately using email settings from `.env`.

They read either naming style:

```text
REPORT_TO_EMAIL
SMTP_HOST / SMTP_PORT / SMTP_USERNAME / SMTP_PASSWORD
SPRING_MAIL_HOST / SPRING_MAIL_PORT / SPRING_MAIL_USERNAME / SPRING_MAIL_PASSWORD
```

If the recipient, username, or password is missing, the scripts stop with a clear error.

## Safer Preview Pattern

Run preview mode:

```bash
../../../.venv/bin/python 04_env_preview_pattern/send_plain_email_env_preview.py
```

Send mode:

```bash
../../../.venv/bin/python 04_env_preview_pattern/send_plain_email_env_preview.py --send
```

Lesson 4 reads the same values from `.env`:

```text
REPORT_TO_EMAIL
SMTP_HOST / SMTP_PORT / SMTP_USERNAME / SMTP_PASSWORD
SPRING_MAIL_HOST / SPRING_MAIL_PORT / SPRING_MAIL_USERNAME / SPRING_MAIL_PASSWORD
```

## Attachment Lab

The attachment example uses this course file:

```text
Course/Transact-SQL training_program.pdf
```
