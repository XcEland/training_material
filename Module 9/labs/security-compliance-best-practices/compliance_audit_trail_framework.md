# Compliance and Audit Trail Framework

## Purpose

Central Bank systems must show who accessed or changed sensitive data, when the action happened, what was changed, and whether the change was authorised.

## Minimum Audit Fields

| Field | Purpose |
|---|---|
| AuditID | Unique audit event identifier |
| EventTime | UTC timestamp of the event |
| LoginName | SQL Server login or application identity |
| UserName | Database user context |
| ProcedureName | Stored procedure or process that performed the action |
| ActionTaken | Business action in plain language |
| EntityName | Table, report, account, or customer entity affected |
| EntityKey | Primary key or business key |
| OldValue | Previous value for sensitive updates |
| NewValue | New value for sensitive updates |
| Reason | Business reason or approval reference |

## Privacy Controls

- Do not store full passwords, tokens, or secret keys in audit tables.
- Mask national identifiers and account numbers when full values are not required.
- Restrict audit table access to compliance, security, and database administration roles.
- Retain audit records according to the organisation's data retention policy.

## Evidence Questions

1. Can we identify who performed the action?
2. Can we identify what changed?
3. Can we prove the change was made through an approved procedure?
4. Can we detect failed or suspicious attempts?
5. Can we produce the record for internal or external audit?
