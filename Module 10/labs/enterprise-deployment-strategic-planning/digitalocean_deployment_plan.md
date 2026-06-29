# DigitalOcean Deployment Plan

## Scope

Deploy the Module 10 capstone portal that publishes programme evidence from Modules 6-9:

- WEO reporting metrics
- monitoring dashboard
- security assessment report
- compliance evidence pack
- KPI and ROI summary

## Deployment Architecture

```text
Learner workstation
  -> prepare deployment bundle
  -> build Docker image
  -> run locally for validation
  -> push to registry or copy to Droplet
  -> deploy on DigitalOcean
```

## Environments

| Environment | Purpose | Hosting Option | Release Gate |
| --- | --- | --- | --- |
| Development | Local validation | Python / Docker Compose | Unit tests pass |
| Test | Container validation | Local Docker Compose | Health check passes |
| Staging | Cloud validation | DigitalOcean Droplet or App Platform | Security and stakeholder review |
| Production | Executive-visible portal | Approved DigitalOcean target | Change approval and rollback plan |

## Release Steps

1. Regenerate Module 6-9 outputs.
2. Run `python 03_prepare_deployment_bundle.py`.
3. Run Module 10 tests.
4. Build Docker image.
5. Run local container and check `/health`.
6. Deploy to Droplet or App Platform.
7. Confirm homepage and `/health`.
8. Capture deployment evidence.
9. Notify stakeholders.

## Rollback Strategy

| Failure | Rollback Action |
| --- | --- |
| Health check fails | Revert to previous Docker image tag |
| Missing artifact | Re-run bundle preparation and redeploy |
| Security issue found | Remove published artifact, rebuild image, redeploy |
| Cloud platform failure | Run on alternate Droplet or local emergency export |

## Security Controls

- No secrets are copied into `published_artifacts`.
- Runtime configuration uses environment variables.
- Container image should be scanned before production.
- Production should use HTTPS.
- Access should be restricted according to data classification.
- Deployment approval should include security, operations, and business owners.

## Success Metrics

| Metric | Target |
| --- | --- |
| Deployment success rate | 95 percent or higher |
| Rollback readiness | Tested before production |
| Health check availability | `/health` returns status ok |
| Evidence completeness | All required Module 6-9 artifacts published |
| Security findings | No unresolved High findings |
| Executive readiness | Capstone proposal passes panel rubric |
