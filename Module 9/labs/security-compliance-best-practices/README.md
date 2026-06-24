# Security, Compliance, and Best Practices

This Module 9 lab moves from beginner security concepts to a practical assessment exercise. It is intentionally simple enough for beginners, but it introduces the same habits expected in production Central Bank systems.

## Learning Order

1. Run `01_database_security_rbac_sql_injection.sql` to study roles, permissions, unsafe dynamic SQL, safe dynamic SQL, and audit logging.
2. Review `02_python_secure_coding_credentials.py` to understand environment variables, connection-string redaction, and secure configuration checks.
3. Complete `python_security_threat_model.md` to connect Python coding choices to realistic database application risks.
4. Run `03_security_assessment.py` against the Module 9 sample files, then against earlier course modules.
5. Complete the compliance, code review, deployment, and KPI worksheets.
6. Run the tests.

## Files

```text
Module 9/labs/security-compliance-best-practices/
├── README.md
├── 01_database_security_rbac_sql_injection.sql
├── 02_python_secure_coding_credentials.py
├── 03_security_assessment.py
├── compliance_audit_trail_framework.md
├── python_security_threat_model.md
├── code_review_quality_assurance_checklist.md
├── deployment_change_management_plan.md
├── kpi_roi_framework.md
├── security_assessment_worksheet.md
├── config/
│   └── security_rules.json
├── tests/
│   └── test_security_assessment.py
└── outputs/
```

## Security Principle

In SQL Server, the principle of least privilege means every database role receives only the permissions required for its function. Application service accounts should not use `db_owner` or `sysadmin`.

For dynamic SQL, use `sp_executesql` with parameters instead of string concatenation. This is the main SQL injection prevention pattern in T-SQL.

## Deployment Discipline

Every change should pass four gates:

1. Development: unit tested and peer reviewed.
2. Test: integration tested against a production-like dataset.
3. Staging: performance tested and security scanned.
4. Production: released through a documented procedure with a rollback plan.

## Run the Python Labs

From this folder:

```bash
python 02_python_secure_coding_credentials.py
python 03_security_assessment.py --path .
pytest -q
```

To scan a wider area of the repository:

```bash
python 03_security_assessment.py --path "../../.."
```
