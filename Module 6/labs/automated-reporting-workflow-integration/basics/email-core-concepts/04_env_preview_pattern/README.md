# Lesson 4: Environment-Based Email Preview Pattern

The first three lessons keep the code very simple so beginners can see how
email sending works.

This lesson introduces a safer structure:

- credentials are read from `.env`
- the email is saved as a preview file first
- the email sends only when `--send` is used

Run preview mode:

```bash
python send_plain_email_env_preview.py
```

Send mode:

```bash
python send_plain_email_env_preview.py --send
```
