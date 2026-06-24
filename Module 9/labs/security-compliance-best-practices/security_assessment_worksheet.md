# Security Assessment Worksheet

Use this worksheet for the hands-on exercise: assess existing database procedures and Python scripts, then recommend improvements.

## Scope

| Item | File/Procedure | Business Purpose | Owner |
|---|---|---|---|
| 1 |  |  |  |
| 2 |  |  |  |
| 3 |  |  |  |

## Findings

| Finding | Severity | Evidence | Recommended Fix | Owner | Due Date |
|---|---|---|---|---|---|
| Unsafe dynamic SQL | High |  | Replace concatenation with `sp_executesql` parameters |  |  |
| Broad permissions | High |  | Replace with least-privilege role grants |  |  |
| Hardcoded credential | High |  | Move secret to environment variable or secret manager |  |  |
| Missing audit trail | Medium |  | Add audit table and procedure logging |  |  |
| Missing error logging | Medium |  | Add structured logs and exception handling |  |  |

## Acceptance Criteria

- Critical and high findings are fixed before release.
- Medium findings have an approved remediation plan.
- Audit logging exists for sensitive data changes.
- Dynamic SQL uses parameters.
- Python scripts do not print or log secrets.
