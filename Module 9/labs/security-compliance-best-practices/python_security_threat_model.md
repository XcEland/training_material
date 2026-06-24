# Python Database Application Threat Model

## Scope

This threat model applies to Python scripts that connect to SQL Server, extract or transform regulated data, write files, send reports, or load results back to the database.

## Key Threats and Controls

| Threat | Example | Control |
|---|---|---|
| Credential exposure | Password stored in source code or printed in logs | Use environment variables or a secret manager; redact secrets in logs |
| SQL injection | User input inserted into SQL text using f-strings | Use bound parameters through `pyodbc`, SQLAlchemy, or stored procedures |
| Excessive privileges | Script connects using `sa` or `db_owner` account | Use application roles with only required permissions |
| Data leakage | Reports export full identifiers or sensitive values | Mask sensitive fields and restrict output folder access |
| Unhandled failures | Script fails silently or partially loads data | Use structured logging, transactions, and clear failure handling |
| Dependency risk | Unpinned or unknown packages are installed in production | Review dependencies and install from approved sources |

## Review Questions

1. Where do credentials come from?
2. Can a secret appear in terminal output, logs, screenshots, or reports?
3. Does the database account have more permissions than the script needs?
4. Are SQL values passed as parameters?
5. Is every failure visible in logs?
6. Can a reviewer reproduce the deployment and rollback steps?
