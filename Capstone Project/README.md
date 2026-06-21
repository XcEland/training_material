# Capstone Project

The capstone is developed progressively across Modules 1 to 10. Learners will choose the final project topic with the facilitator, but the recommended direction is a practical data pipeline that supports research, reporting, automation, and Enterprise Data Warehouse readiness.

## Working Theme

Possible theme:

**Automated Research Data Ingestion, Validation, and Reporting Pipeline**

The final topic may focus on one data domain, such as exchange rates, inflation indicators, reserves, financial statistics, or another area agreed with the learners.

## Design Principle

Use a separate SQL Server schema for capstone objects:

```text
cap
```

This keeps capstone tables, views, procedures, and logs separate from the module lab schemas.

## Documentation and Version Control

Use Git and GitHub to document and version-control the capstone work.

Expected use:

- keep project files in the capstone folder
- commit changes at the end of each module stage
- use clear commit messages
- keep README files updated as the project evolves
- use GitHub as the shared record of progress, decisions, and final deliverables

## Stage Structure

```text
Capstone Project/
├── README.md
├── Module 1/
├── Module 2/
├── Module 3/
├── Module 4/
├── Module 5/
├── Module 6/
├── Module 7/
├── Module 8/
├── Module 9/
└── Module 10/
```

## Expected Progression

| Stage | Capstone Focus |
| --- | --- |
| Module 1 | Define the data domain, basic database objects, sample records, and simple queries. |
| Module 2 | Add advanced querying, validation queries, CTEs, window functions, indexing, and performance evidence. |
| Module 3 | Add reusable database objects such as views, stored procedures, functions, triggers, or error logs. |
| Module 4 | Add Python extraction, cleaning, transformation, and SQL Server loading. |
| Module 5 | Add statistics, analysis, visualisation, and reproducible reporting. |
| Module 6 | Add automation or scheduled workflow design. |
| Module 7 | Add data quality controls, monitoring, or exception handling improvements. |
| Module 8 | Add integration with external/internal data sources where relevant. |
| Module 9 | Add deployment, documentation, governance, or operational handover material. |
| Module 10 | Final integration, presentation, demonstration, and reflection. |

## Final Deliverables

By the end of the programme, each capstone should include:

- chosen business problem and data domain
- database schema and data model
- data ingestion or loading process
- validation and audit approach
- analytical outputs
- reproducible report or presentation
- explanation of business value and EDW relevance

On the final day, each learner or project team will deliver a 15-minute capstone presentation and demonstration.
