# Change Management and Release Checklist

## Development Gate

| Check | Evidence | Complete |
|---|---|---|
| Code written against approved requirement | Requirement ID or user story |  |
| Unit tests passed | Test output |  |
| Peer review completed | Reviewer name and date |  |
| Secrets are not stored in source code | Security review note |  |

## Test Gate

| Check | Evidence | Complete |
|---|---|---|
| Integration tests passed | Test report |  |
| Data reconciliation completed | Row counts/totals |  |
| Error handling verified | Failure test evidence |  |
| Business owner reviewed output | Sign-off note |  |

## Staging Gate

| Check | Evidence | Complete |
|---|---|---|
| Performance baseline compared | Baseline worksheet |  |
| Security scan completed | Security findings report |  |
| Rollback tested | Rollback result |  |
| Deployment timing estimated | Release rehearsal notes |  |

## Production Gate

| Check | Evidence | Complete |
|---|---|---|
| Change window approved | Change ticket |  |
| Backup confirmed | Backup reference |  |
| Deployment completed | Release log |  |
| Post-deployment monitoring completed | Dashboard/log evidence |  |
