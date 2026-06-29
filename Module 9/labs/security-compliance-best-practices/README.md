# Security, Compliance, and Best Practices

This Module 9 lab moves from core security concepts to a practical assessment exercise. It uses readable examples while introducing the same habits expected in production Central Bank systems.

## Learning Order

1. Run `00_security_orientation_walkthrough.py` to identify what Module 9 is securing from Modules 6-8.
2. Run `01_beginner_rbac_sql_injection_walkthrough.sql` if SQL Server is available.
3. Run `02_database_security_rbac_sql_injection.sql` to study roles, permissions, unsafe dynamic SQL, safe dynamic SQL, WEO distribution audit logging, and compliance access.
4. Review `03_python_secure_coding_credentials.py` to understand environment variables, connection-string redaction, and secure configuration checks.
5. Complete `python_security_threat_model.md` to connect Python coding choices to realistic database application risks.
6. Run `04_security_assessment.py` against the Module 9 sample vulnerable files, then against earlier course modules.
7. Run `05_audit_compliance_evidence_demo.py` to build a compliance evidence pack.
8. Run `06_kpi_roi_calculator.py` to connect security and automation work to measurable value.
9. Complete the compliance, code review, deployment, and KPI worksheets.
10. Run the tests.

## Files

```text
Module 9/labs/security-compliance-best-practices/
├── README.md
├── 00_security_orientation_walkthrough.py
├── 01_beginner_rbac_sql_injection_walkthrough.sql
├── 02_database_security_rbac_sql_injection.sql
├── 03_python_secure_coding_credentials.py
├── 04_security_assessment.py
├── 05_audit_compliance_evidence_demo.py
├── 06_kpi_roi_calculator.py
├── day9_learning_guide.md
├── compliance_audit_trail_framework.md
├── python_security_threat_model.md
├── code_review_quality_assurance_checklist.md
├── deployment_change_management_plan.md
├── kpi_roi_framework.md
├── security_assessment_worksheet.md
├── .env.example
├── config/
│   └── security_rules.json
├── sample_assessment_targets/
│   ├── secure_report_export.py
│   ├── vulnerable_dynamic_sql.sql
│   └── vulnerable_report_export.py
├── tests/
│   └── test_security_assessment.py
└── outputs/
```

## Security Principle

In SQL Server, the principle of least privilege means every database role receives only the permissions required for its function. Application service accounts should not use `db_owner` or `sysadmin`.

For dynamic SQL, use `sp_executesql` with parameters instead of string concatenation. This is the main SQL injection prevention pattern in T-SQL.

## Dataset And System Linkage

The labs use artifacts from the earlier course build:

- Module 6 WEO report outputs, email preview status, and monthly run metrics
- Module 7 IMF/BIS integration summary and quality gate result
- Module 8 monitoring dashboard and observability assessment

This lets students assess security around the actual reporting and integration workflows they have already built.

## Deployment Discipline

Every change should pass four gates:

1. Development: unit tested and peer reviewed.
2. Test: integration tested against a production-like dataset.
3. Staging: performance tested and security scanned.
4. Production: released through a documented procedure with a rollback plan.

## Run the Python Labs

From this folder:

```bash
python 00_security_orientation_walkthrough.py
python 03_python_secure_coding_credentials.py
python 04_security_assessment.py --path sample_assessment_targets
python 05_audit_compliance_evidence_demo.py
python 06_kpi_roi_calculator.py
pytest -q
```

To scan a wider area of the repository:

```bash
python 04_security_assessment.py --path "../../.."
```

## Expected Outputs

```text
outputs/security_data_inventory.json
outputs/python_security_posture_review.json
outputs/security_assessment_report.json
outputs/audit_trail_sample.json
outputs/compliance_evidence_pack.json
outputs/kpi_roi_summary.json
```

## Exercise Deliverable

Submit:

- generated security data inventory
- SQL RBAC and SQL injection prevention walkthrough notes
- Python security posture review
- security assessment JSON report
- compliance evidence pack
- completed threat model
- completed security assessment worksheet
- completed code review checklist
- completed deployment/change plan
- completed KPI/ROI framework
