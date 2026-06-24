# Operational Observability Review

Use this checklist after generating `outputs/monitoring_dashboard.html`.

## Dashboard Assessment

| Standard | Evidence | Pass/Fail |
| --- | --- | --- |
| Includes database performance metrics | Active sessions, query duration, database size panels |  |
| Includes Python workflow metrics | duration, peak memory, error count panels |  |
| Includes capacity planning output | 12-month projection table |  |
| Includes alert levels | Normal / Warning / Critical labels |  |
| Uses documented thresholds | `config/monitoring_thresholds.json` |  |
| Can run without SQL Server using fallback metrics | `monitoring_snapshot.json` |  |
| Can use SQL Server when available | SQL setup script and `db_utils.py` |  |

## Alert Review

- Number of warning alerts:
- Number of critical alerts:
- Most urgent issue:
- Recommended escalation:

## Production Readiness Gaps

- Authentication and access control:
- Dashboard hosting:
- Alert delivery:
- Retention and audit:
- Scheduled refresh:
- Owner and support model:
