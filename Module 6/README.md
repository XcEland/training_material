# Module 6: Automated Reporting and Workflow Integration

Module 6 turns the analytical outputs from Module 5 into an automated monthly reporting workflow. Students design scheduling architecture, generate professional Jinja2 reports, send or preview stakeholder notifications, manage environment configuration, and evaluate the Phase 2 Simulation pipeline.

## Lab

```text
Module 6/labs/automated-reporting-workflow-integration/
```

The lab covers:

- task scheduling with Windows Task Scheduler, cron, and Python scheduling libraries
- scheduler decision criteria for Central Bank reporting workflows
- email automation and stakeholder notification logic
- Jinja2 template-based executive reporting
- environment variables and deployment configuration
- T-SQL extraction, Python processing, formatted report generation, and distribution
- Phase 2 Simulation evaluation against reliability, output quality, and communication benchmarks

The lab uses `TrainingDB` and creates objects under the `m6` schema when SQL Server is available. The Python scripts also include generated fallback data so the workflow can run without SQL Server during practice.
