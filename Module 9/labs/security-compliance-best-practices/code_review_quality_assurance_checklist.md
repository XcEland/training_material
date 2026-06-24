# Code Review and Quality Assurance Checklist

Use this checklist before any SQL or Python automation is promoted beyond development.

## SQL Review

| Check | Pass/Fail | Notes |
|---|---|---|
| Uses least-privilege roles instead of broad permissions |  |  |
| Does not grant `db_owner` or `sysadmin` to application accounts |  |  |
| Dynamic SQL uses `sp_executesql` with parameters |  |  |
| Stored procedures validate input values |  |  |
| Sensitive writes are audited |  |  |
| Error handling uses `TRY...CATCH` where needed |  |  |
| Deployment script is repeatable or clearly versioned |  |  |

## Python Review

| Check | Pass/Fail | Notes |
|---|---|---|
| Credentials come from environment variables or secret management |  |  |
| Logs redact passwords, tokens, and connection strings |  |  |
| SQL calls use bound parameters |  |  |
| Exceptions are logged with enough diagnostic detail |  |  |
| File paths are configurable |  |  |
| Tests cover validation and failure paths |  |  |
| Dependencies are documented |  |  |

## Approval Record

| Role | Name | Date | Decision |
|---|---|---|---|
| Developer |  |  |  |
| Peer Reviewer |  |  |  |
| Database Reviewer |  |  |  |
| Security/Compliance Reviewer |  |  |  |
