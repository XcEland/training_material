# Advanced T-SQL Query Design and Optimization

This Module 2 lab uses a Central Bank-style financial transactions dataset in `TrainingDB` under the `m2` schema.

Guiding documents:

- `Transact-SQL training_program.pdf`
- `Transact-SQL  workbook.pdf`
- `Docs/06_JOINS_and_SET.pdf`
- `Docs/08_Aggregation_Analytical_Functions.pdf`
- `Docs/09_Advanced_SQL_Techniques.pdf`
- `Docs/10_SQL_30_Performance_Tips.pdf`

## Learning Order

1. Prepare a financial transactions dataset.
2. Practice joins from simple two-table joins to multi-table joins.
3. Practice subqueries.
4. Practice CTEs.
5. Practice window functions.
6. Prepare larger demo data for execution-plan and indexing comparisons.
7. Demonstrate execution plans and statistics.
8. Demonstrate indexes from simple to composite patterns.
9. Practice MERGE operations.
10. Practice bulk-style `INSERT ... SELECT` summary loading.
11. Practice transactions and TRY/CATCH error handling.
12. Review concurrency and locking patterns.
13. Practice table expressions.
14. Complete a data lab: optimise poor queries and record before/after metrics.

## Files

```text
Module 2/labs/advanced-t-sql-query-design-optimization/
├── README.md
├── 01_setup_financial_dataset.sql
├── 01_setup_financial_dataset.md
├── 01_setup_financial_dataset_dbeaver.sql
├── 02_joins.sql
├── 02_joins.md
├── 03_subqueries.sql
├── 03_subqueries.md
├── 04_ctes.sql
├── 04_ctes.md
├── 05_window_functions.sql
├── 05_window_functions.md
├── 06_large_scale_demo_data.sql
├── 06_large_scale_demo_data_dbeaver.sql
├── 06_large_scale_demo_data.md
├── 06_execution_plans_demo.sql
├── 06_execution_plans_demo.md
├── 07_indexes_demo.sql
├── 07_indexes_demo.md
├── 08_merge_operations.sql
├── 08_merge_operations.md
├── 09_bulk_insert_select_summary.sql
├── 09_bulk_insert_select_summary.md
├── 10_transactions_error_handling.sql
├── 10_transactions_error_handling.md
├── 11_concurrency_notes.sql
├── 11_concurrency_notes.md
├── 12_data_lab_query_optimization_benchmark.sql
├── 12_data_lab_query_optimization_benchmark.md
├── 13_table_expressions.sql
├── 13_table_expressions.md
└── optimization_findings_template.md
```

The `.sql` files are complete runnable solutions. The matching `.md` files are live-coding scaffolds with table context, field names, preview queries, and lesson comments.

## DBeaver Setup

Connect to the `TrainingDB` database, then run:

```text
01_setup_financial_dataset_dbeaver.sql
06_large_scale_demo_data_dbeaver.sql
```

The standard setup file uses `GO` batch separators for `sqlcmd` and SSMS. In DBeaver, use the DBeaver setup file above, or run SQL files with **Execute SQL Script** so batch separators are handled correctly.

The large-scale demo data script inserts generated transaction records until `m2.FinancialTransactions` has about `300,000` rows. Run it before the execution-plan and indexing demos.

## Linux Run Commands

Run from the project root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"

sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 2/labs/advanced-t-sql-query-design-optimization/01_setup_financial_dataset.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/02_joins.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/03_subqueries.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/04_ctes.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/05_window_functions.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/06_large_scale_demo_data.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/06_execution_plans_demo.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/07_indexes_demo.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/08_merge_operations.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/09_bulk_insert_select_summary.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/10_transactions_error_handling.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/11_concurrency_notes.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/12_data_lab_query_optimization_benchmark.sql"
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -d TrainingDB -i "Module 2/labs/advanced-t-sql-query-design-optimization/13_table_expressions.sql"
```

## Windows Run Commands

For Windows Authentication in PowerShell:

```powershell
cd "$HOME\Desktop\Trainingcred Institute"

sqlcmd -S localhost -E -C -i "Module 2\labs\advanced-t-sql-query-design-optimization\01_setup_financial_dataset.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\02_joins.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\03_subqueries.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\04_ctes.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\05_window_functions.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\06_large_scale_demo_data.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\06_execution_plans_demo.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\07_indexes_demo.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\08_merge_operations.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\09_bulk_insert_select_summary.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\10_transactions_error_handling.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\11_concurrency_notes.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\12_data_lab_query_optimization_benchmark.sql"
sqlcmd -S localhost -E -C -d TrainingDB -i "Module 2\labs\advanced-t-sql-query-design-optimization\13_table_expressions.sql"
```

If using SQL Server Express, replace `localhost` with `localhost\SQLEXPRESS`.

## Data Lab Deliverable

Run `12_data_lab_query_optimization_benchmark.sql`, then complete `optimization_findings_template.md`.

Record:

- Original performance issue
- Query rewrite or index applied
- Logical reads before and after
- CPU or elapsed time before and after
- Execution plan operators that changed
- A short recommendation for production use

For execution-plan and indexing demos, compare the values printed in the Messages output from `SET STATISTICS IO ON` and `SET STATISTICS TIME ON`: logical reads, CPU time, elapsed time, and plan operators such as scan, seek, sort, nested loops, hash match, and key lookup.

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
