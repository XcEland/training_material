# Deployment and Change Management Plan

## Four Release Gates

| Gate | Required Evidence | Exit Criteria |
|---|---|---|
| Development | Unit tests, peer review, local execution evidence | Code is reviewed and passes local tests |
| Test | Integration tests against a production-like dataset | Data outputs match expected results |
| Staging | Performance test, security scan, rollback test | Performance and security thresholds are met |
| Production | Approved release ticket, deployment script, rollback plan | Deployment completed and monitored |

## Release Procedure

1. Confirm the business owner and technical owner.
2. Confirm the exact scripts and versions being deployed.
3. Back up affected database objects or confirm restore point.
4. Run pre-deployment checks.
5. Deploy during an approved change window.
6. Run post-deployment validation queries.
7. Monitor logs and performance dashboards.
8. Record release outcome and lessons learned.

## Rollback Plan

| Item | Detail |
|---|---|
| Rollback trigger | Error rate, failed validation, performance breach, stakeholder rejection |
| Rollback owner |  |
| Rollback script/location |  |
| Data recovery action |  |
| Communication channel |  |
| Post-rollback validation |  |

## Production Deployment Rule

No database or Python automation change should skip Development, Test, Staging, or Production approval gates. Skipping gates increases the risk of regulatory reporting and financial operations incidents.
