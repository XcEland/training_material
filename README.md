# Transact-SQL and Python Programming Course

This repository contains practical course materials for learning SQL Server, Transact-SQL, Python programming, database connectivity, data manipulation, automation, analytics, reporting, integration, monitoring, security, and enterprise deployment planning.

The project is organized as ten module-based labs, setup guides, practice scripts, and a staged capstone project.

## Repository Structure

```text
.
├── Setup/
├── Module 1/
├── Module 2/
├── Module 3/
├── Module 4/
├── Module 5/
├── Module 6/
├── Module 7/
├── Module 8/
├── Module 9/
├── Module 10/
├── Practice/
├── Docs/
├── Slides/
└── Capstone Project/
```

## Modules

| Module | Focus | Main Lab Folder |
|---|---|---|
| Module 1 | Foundations, SQL fundamentals, Python basics, Git, and Python-to-SQL Server connectivity | `Module 1/labs/` |
| Module 2 | Advanced T-SQL query design, joins, subqueries, CTEs, window functions, execution plans, indexes, transactions, and optimization | `Module 2/labs/advanced-t-sql-query-design-optimization/` |
| Module 3 | Stored procedures, functions, triggers, dynamic SQL, error handling, audit logging, and automated validation | `Module 3/labs/stored-procedures-functions-triggers-automation/` |
| Module 4 | Python database connectivity, pandas, NumPy, file I/O, ETL workflows, and notebook-based data preparation | `Module 4/labs/python-data-manipulation-database-connectivity/` |
| Module 5 | SciPy statistics, Matplotlib/Seaborn visualization, Scikit-learn basics, time series analysis, and analytical reporting | `Module 5/labs/statistical-analysis-data-visualization-python/` |
| Module 6 | Automated reporting, scheduling, email/notification workflows, Jinja2 reports, and environment configuration | `Module 6/labs/automated-reporting-workflow-integration/` |
| Module 7 | REST API consumption, authentication, rate limiting, JSON/XML parsing, web scraping, validation, and SQL Server loading | `Module 7/labs/api-integration-external-data-sources/` |
| Module 8 | SQL Server monitoring with DMVs, Query Store, Extended Events, Python profiling, logging, capacity planning, and dashboards | `Module 8/labs/performance-monitoring-system-optimization/` |
| Module 9 | Role-based access control, SQL injection prevention, Python credential safety, compliance, audit trails, code review, and secure deployment controls | `Module 9/labs/security-compliance-best-practices/` |
| Module 10 | Enterprise deployment planning, change management, user adoption, KPI/ROI frameworks, strategic roadmaps, and executive capstone proposals | `Module 10/labs/enterprise-deployment-strategic-planning/` |

## Main Areas

- `Setup/` contains environment setup notes for Linux and Windows.
- `Practice/` contains additional SQL practice scripts and datasets.
- `Docs/` contains supporting course reference documents.
- `Slides/` contains presentation support material where available.
- `Capstone Project/` contains the staged project structure developed across the modules.

## Lab Pattern

SQL labs include runnable `.sql` files, comments, and Markdown scaffold files where useful.

Python labs use a mix of runnable `.py` files, Jupyter notebooks, configuration examples, sample data, tests, and documentation templates. Notebook-based modules include install/setup cells so learners can run the material in local Jupyter environments or Google Colab where practical.

## Lab Update Policy

When adding new examples, datasets, or discussion outcomes to an existing module, do not delete the existing labs. Add the new material at the top of the relevant lab flow where it is the preferred teaching example, then keep earlier examples as secondary practice, fallback data, or extension exercises.

If a newer dataset is introduced for a topic, use it first in the lesson sequence where possible. Existing datasets should remain in the repository unless they are broken, duplicated, or explicitly replaced by the facilitator.

## Typical Workflow

1. Complete the setup guide for your operating system.
2. Start SQL Server and verify connectivity.
3. Run the module setup script.
4. Work through each lab in order.
5. Use the scaffold files for guided live coding.
6. Commit progress with Git after each meaningful change.
7. Run tests where provided with `pytest -q`.
8. Apply module concepts to the staged capstone project.

## Version Control

Use Git and GitHub to track:

- lab progress
- capstone stages
- documentation updates
- code changes
- final project deliverables

Commit messages should be short and clear, for example:

```text
Add Module 2 window function lab scaffolds
Update SQL Python connection README
Add capstone Module 1 planning notes
```

## Capstone
The capstone project is developed progressively from Module 1 to Module 10. Learners choose the final topic with the facilitator, then build the project in stages as new SQL and Python concepts are introduced.

Final delivery includes a 15-minute project presentation and demonstration. By Module 10, learners should be able to present a complete deployment plan, success metrics framework, ROI scenario, and strategic roadmap.

Slides: 
Slide 1: https://1drv.ms/p/c/86b2518f75840e31/IQB-saCuuUGHS4DU-OPJlGmZASNNNArs0wbUVwWIg_tggoI?e=A0phZg

Slide 2: https://1drv.ms/p/c/86b2518f75840e31/IQDUnStwK1DeS4QJkG02DvK9ASG-mnlVkI2_Cqn_e36oA2c?e=NcrNOz

Slide 3: https://1drv.ms/p/c/86b2518f75840e31/IQD3RZBnejBISJpW3ApT9hY5AYmAu9i8ugs88jxnxDxYnQk?e=HHLDS0

drive link: https://drive.google.com/drive/folders/1thgDnguXjQzKlCNCoveWp6aEaO9G2qb7?usp=sharing
https://drive.google.com/drive/folders/1thgDnguXjQzKlCNCoveWp6aEaO9G2qb7?usp=sharing

## Git Commands

Use `main` if it is the current source-of-truth branch for the class. If the facilitator specifically says to use the `module3` branch, replace `main` with `module3` in the commands below.

### Pull Latest Changes While Keeping Local Changes

Use this when you have local work that you do not want to lose:

```bash
git status
git stash push -u -m "my local work before pulling"
git checkout main
git pull --rebase origin main
git stash pop
```

If `git stash pop` creates conflicts, fix the conflicted files, then run:

```bash
git add .
git commit -m "Resolve local changes after pulling latest main"
```

### Pull Latest Changes When You Have No Local Changes

```bash
git checkout main
git pull --rebase origin main
```
