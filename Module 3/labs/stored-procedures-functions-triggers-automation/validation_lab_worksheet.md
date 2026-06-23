# Validation Lab Worksheet

Use this during the Module 3 hands-on lab and group walkthrough.

## Stored Procedure Inventory

- Procedure name:
- Business purpose:
- Input parameters:
- Output parameters:
- Return code meaning:
- Error handling used:
- Logging table used:

## Validation Run

- Target schema:
- Target table:
- Rule set:
- Run ID:
- Total violations:

## Rules Reviewed

| Rule name | Severity | Violations found | Business risk |
| --- | --- | ---: | --- |
| | | | |

## Dynamic SQL Security Review

- Uses `QUOTENAME` for object names:
- Uses `sp_executesql` for parameterised execution:
- Avoids direct string concatenation of user values:
- Restricts validation to configured rules:
- Injection risk rating:

## Audit and Error Logging

- Successful execution logged:
- Failed execution logged:
- Errors written to `m3.ErrorLog`:
- Data changes written to `m3.AuditLog`:

## Execution Log Diagnosis

- Procedure tested:
- Failure scenario used:
- Was a `Failed` row written to `m3.ProcedureExecutionLog`:
- Was `EndedAt` populated:
- Was a detailed error written to `m3.ErrorLog`:
- Logging gap found:
- Corrective logging improvement:

## Enterprise Validation Procedure

- Procedure name:
- Starts logging before validation checks:
- Creates `m3.ValidationRun` row:
- Creates `m3.ValidationViolation` rows:
- Updates final run status:
- Prints diagnostic details in `CATCH`:
- Writes failures to `m3.ErrorLog`:
- Writes success/failure to `m3.ProcedureExecutionLog`:
- Return code meaning:
- High-severity quality gate used:

## Reflection

- First real Central Bank validation rule to automate:
- Production risk this would reduce:
- Change needed before production deployment:
