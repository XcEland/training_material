# Advanced T-SQL Query Design and Optimization

This Module 2 lab supports the live demonstration and data lab for Day 2. It uses a Central Bank-style financial transactions dataset in `TrainingDB` under the `m2` schema.

Guiding documents:

- `Transact-SQL training_program.pdf`
- `Transact-SQL  workbook.pdf`
- `Docs/06_JOINS_and_SET.pdf`
- `Docs/08_Aggregation_Analytical_Functions.pdf`
- `Docs/09_Advanced_SQL_Techniques.pdf`
- `Docs/10_SQL_30_Performance_Tips.pdf`

## Learning Order

1. Prepare a financial transactions dataset.
2. Practice joins, subqueries, CTEs, and window functions.
3. Demonstrate execution plans, statistics, and indexes.
4. Practice MERGE, table expressions, and bulk-style loading.
5. Practice TRY/CATCH, transactions, rollback, and concurrency notes.
6. Complete a data lab: optimise poor queries and record before/after metrics.

## Files

```text
Module 2/labs/advanced-t-sql-query-design-optimization/
├── README.md
├── 01_setup_financial_dataset.sql
├── 02_advanced_joins_subqueries_ctes_window_functions.sql
├── 03_execution_plans_and_indexes_demo.sql
├── 04_merge_table_expressions_bulk_operations.sql
├── 05_transactions_error_handling_concurrency.sql
├── 06_data_lab_query_optimization_benchmark.sql
└── optimization_findings_template.md
```

## Linux Run Commands

Run from the project root:

```bash
cd "$HOME/Desktop/IRES"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 2/labs/advanced-t-sql-query-design-optimization/01_setup_financial_dataset.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/02_advanced_joins_subqueries_ctes_window_functions.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/03_execution_plans_and_indexes_demo.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/04_merge_table_expressions_bulk_operations.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/05_transactions_error_handling_concurrency.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/06_data_lab_query_optimization_benchmark.sql"
```

## Windows Run Commands

For Windows Authentication in PowerShell:

```powershell
cd "$HOME\Desktop\IRES"

sqlcmd -S localhost -E -C -i "Module 2\labs\advanced-t-sql-query-design-optimization\01_setup_financial_dataset.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\02_advanced_joins_subqueries_ctes_window_functions.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\03_execution_plans_and_indexes_demo.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\04_merge_table_expressions_bulk_operations.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\05_transactions_error_handling_concurrency.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\06_data_lab_query_optimization_benchmark.sql"
```

If using SQL Server Express, replace `localhost` with `localhost\SQLEXPRESS`.

## Live Demonstration Notes

For the execution plan demo, use SSMS:

1. Open `03_execution_plans_and_indexes_demo.sql`.
2. Turn on **Include Actual Execution Plan**.
3. Run the poor query first and inspect scans, sorts, row estimates, and reads.
4. Create the recommended indexes.
5. Run the optimised query and compare logical reads and elapsed time.

## Data Lab Deliverable

Run `06_data_lab_query_optimization_benchmark.sql`, then complete `optimization_findings_template.md`.

Each learner should record:

- Original performance issue
- Query rewrite or index applied
- Logical reads before and after
- CPU or elapsed time before and after
- Execution plan operators that changed
- A short recommendation for production use

## Quick Check

```sql
SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
WHERE s.name = 'm2'
ORDER BY t.name;
```
