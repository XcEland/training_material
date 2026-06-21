# Stored Procedures, Functions, Triggers, and Database Automation

This Module 3 lab covers automated data validation stored procedures with error handling and audit logging.

Guiding documents:

- `Transact-SQL training_program.pdf`
- `Transact-SQL  workbook.pdf`
- `Docs/09_Advanced_SQL_Techniques.pdf`

## Learning Order

1. Prepare regulatory reporting tables with known data quality issues.
2. Build stored procedures with parameters, output values, return codes, and execution logs.
3. Create scalar and table-valued functions for reusable business logic.
4. Add triggers for audit trails and business rule enforcement.
5. Build a secure dynamic SQL validation procedure.
6. Run the hands-on validation lab and complete the worksheet.

## Files

```text
Module 3/labs/stored-procedures-functions-triggers-automation/
├── README.md
├── 01_setup_regulatory_validation_dataset.sql
├── 02_stored_procedure_design_patterns.sql
├── 03_user_defined_functions.sql
├── 04_triggers_audit_and_business_rules.sql
├── 05_secure_dynamic_sql_validation_procedure.sql
├── 06_hands_on_validation_lab.sql
└── validation_lab_worksheet.md
```

## Linux Run Commands

Run from the project root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 3/labs/stored-procedures-functions-triggers-automation/01_setup_regulatory_validation_dataset.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 3/labs/stored-procedures-functions-triggers-automation/02_stored_procedure_design_patterns.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 3/labs/stored-procedures-functions-triggers-automation/03_user_defined_functions.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 3/labs/stored-procedures-functions-triggers-automation/04_triggers_audit_and_business_rules.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 3/labs/stored-procedures-functions-triggers-automation/05_secure_dynamic_sql_validation_procedure.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 3/labs/stored-procedures-functions-triggers-automation/06_hands_on_validation_lab.sql"
```

## Windows Run Commands

For Windows Authentication in PowerShell:

```powershell
cd "$HOME\Desktop\Trainingcred Institute"

sqlcmd -S localhost -E -C -i "Module 3\labs\stored-procedures-functions-triggers-automation\01_setup_regulatory_validation_dataset.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 3\labs\stored-procedures-functions-triggers-automation\02_stored_procedure_design_patterns.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 3\labs\stored-procedures-functions-triggers-automation\03_user_defined_functions.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 3\labs\stored-procedures-functions-triggers-automation\04_triggers_audit_and_business_rules.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 3\labs\stored-procedures-functions-triggers-automation\05_secure_dynamic_sql_validation_procedure.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 3\labs\stored-procedures-functions-triggers-automation\06_hands_on_validation_lab.sql"
```

If using SQL Server Express, replace `localhost` with `localhost\SQLEXPRESS`.

## Data Lab Deliverable

Run `06_hands_on_validation_lab.sql`, then complete `validation_lab_worksheet.md`.

Record:

- Validation procedure parameters used
- Rules executed
- Violations found
- Errors logged
- How the procedure prevents SQL injection
- One real Central Bank validation rule they would automate next

## Quick Check

```sql
SELECT
    s.name AS schema_name,
    o.name AS object_name,
    o.type_desc
FROM sys.objects AS o
INNER JOIN sys.schemas AS s
    ON o.schema_id = s.schema_id
WHERE s.name = 'm3'
ORDER BY o.type_desc, o.name;
```
