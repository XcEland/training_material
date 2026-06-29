# Deployment Option Matrix

Use this matrix during the Module 10 design sprint to decide whether the capstone portal should run on a DigitalOcean Droplet or DigitalOcean App Platform.

| Criteria | Docker On DigitalOcean Droplet | DigitalOcean App Platform |
| --- | --- | --- |
| Best for | Learning infrastructure, SSH, Docker Compose, server logs, patching, rollback | Managed deployment, simpler operations, container image release workflow |
| Student learning value | High infrastructure visibility | High deployment workflow visibility |
| Operational burden | Higher: OS patching, firewall, Docker updates, uptime monitoring | Lower: platform manages runtime infrastructure |
| Cost control | Good for small always-on workloads if one Droplet hosts multiple internal tools | Good for app-focused deployments with managed scaling |
| Security responsibility | More responsibility on the team: hardening, firewall, HTTPS, patching | Shared with platform, but app and data security remain team responsibility |
| Rollback model | Previous image tag or previous Compose bundle | Previous image tag or App Platform deployment rollback |
| Recommended lab use | Demonstrate Docker Compose and server operations | Demonstrate cloud release pipeline and registry deployment |

## Recommendation

For the final capstone, present both options:

1. Use the Droplet plan when the Central Bank wants direct control over host configuration and internal network placement.
2. Use App Platform when the priority is faster managed deployment and lower server administration overhead.

The same Docker image should support both options.
