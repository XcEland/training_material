# Module 9: Security, Compliance, and Best Practices

Module 9 covers the controls that make database and Python automation acceptable in a regulated financial environment. Students implement least-privilege access, prevent SQL injection, protect credentials, document audit trails, and prepare disciplined deployment and review processes.

## Lab

```text
Module 9/labs/security-compliance-best-practices/
```

The lab covers:

- role-based access control using SQL Server database roles
- SQL injection prevention with `sp_executesql` and parameters
- insecure dynamic SQL examples and corrected versions
- Python credential management and secure coding checks
- audit trail and compliance documentation structures
- code review and quality assurance standards
- deployment gates, rollback planning, KPIs, and ROI tracking
- a hands-on security assessment of SQL and Python files

The examples use `TrainingDB` and create training objects under the `m9` schema when SQL Server is available. Python scripts run locally without SQL Server.
