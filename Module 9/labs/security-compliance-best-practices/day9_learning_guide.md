# Day 9 Facilitator Guide: Security, Compliance, and Best Practices

Day 9 turns the systems built in Modules 5-8 into a security assessment case study. Students assess the WEO reporting workflow, IMF/BIS data integration pipeline, and monitoring dashboard through the lens of Central Bank security, auditability, and production readiness.

## Daily Teaching Sequence

| Time | Session | Lab Asset | Facilitator Focus |
| --- | --- | --- | --- |
| 09:00 - 09:30 | Orientation | `00_security_orientation_walkthrough.py` | Security starts by knowing what data, outputs, and workflows exist. |
| 09:30 - 10:30 | Database security | `01_beginner_rbac_sql_injection_walkthrough.sql`, then `02_database_security_rbac_sql_injection.sql` | Least privilege, roles, stored procedures, safe dynamic SQL, and audit logging. |
| 10:45 - 11:15 | Python security | `03_python_secure_coding_credentials.py` | Environment variables, redaction, account privilege review, and secure defaults. |
| 11:15 - 12:00 | Privacy and audit | `05_audit_compliance_evidence_demo.py`, `compliance_audit_trail_framework.md` | Evidence should prove what happened without exposing secrets. |
| 12:00 - 13:00 | Hands-on security assessment | `04_security_assessment.py`, `sample_assessment_targets/` | Find insecure SQL/Python patterns and recommend remediation. |
| 14:00 - 14:45 | Code review and QA | `code_review_quality_assurance_checklist.md`, `security_assessment_worksheet.md` | Translate findings into review gates and acceptance criteria. |
| 14:45 - 15:30 | Module 10 bridge | `deployment_change_management_plan.md`, `06_kpi_roi_calculator.py` | Security fixes need controlled deployment, rollback, KPI, and ROI evidence. |

## Beginner Framing

Use these questions before introducing tools:

- Who should be allowed to read or change this data?
- Is the database account more powerful than the task requires?
- Can user input change the meaning of a SQL command?
- Can a password appear in source code, logs, screenshots, or reports?
- Can we prove who ran the process and what it produced?
- Can a reviewer reproduce the test, deployment, and rollback steps?
- Can the business see measurable value from the automation investment?

## Final Deliverable

Students should submit:

- `outputs/security_data_inventory.json`
- `outputs/python_security_posture_review.json`
- `outputs/security_assessment_report.json`
- `outputs/compliance_evidence_pack.json`
- `outputs/kpi_roi_summary.json`
- completed `python_security_threat_model.md`
- completed `security_assessment_worksheet.md`
- completed `code_review_quality_assurance_checklist.md`
- completed `deployment_change_management_plan.md`
- completed `kpi_roi_framework.md`
