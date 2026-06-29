# Enterprise Deployment and Strategic Planning

This Module 10 lab turns technical implementation into a leadership-ready proposal. It is designed for the final day of the programme: students quantify benefits, plan deployment gates, define adoption actions, build a roadmap, and defend design choices in a simulated executive panel.

## Learning Order

1. Complete `deployment_plan_template.md`.
2. Run `01_kpi_roi_calculator.py` to calculate conservative, base-case, and optimistic ROI scenarios.
3. Review `02_technology_roadmap_builder.py` and update the roadmap input file.
4. Run `03_prepare_deployment_bundle.py` to package Module 6-9 evidence for deployment.
5. Review `deployment/README.md`, `deployment_option_matrix.md`, and `digitalocean_deployment_plan.md`.
6. Run the capstone portal locally, then with Docker Compose.
7. Complete `strategic_technology_roadmap_template.md`.
8. Complete `user_training_adoption_plan.md`.
9. Use `capstone_executive_proposal_template.md` for the final presentation.
10. Use `peer_assessment_rubric.md` during panel review.
11. Run the tests.

## Files

```text
Module 10/labs/enterprise-deployment-strategic-planning/
├── README.md
├── 01_kpi_roi_calculator.py
├── 02_technology_roadmap_builder.py
├── 03_prepare_deployment_bundle.py
├── deployment_plan_template.md
├── digitalocean_deployment_plan.md
├── deployment_option_matrix.md
├── change_management_release_checklist.md
├── user_training_adoption_plan.md
├── strategic_technology_roadmap_template.md
├── capstone_executive_proposal_template.md
├── peer_assessment_rubric.md
├── executive_panel_question_bank.md
├── config/
│   ├── roi_scenarios.json
│   └── roadmap_options.json
├── deployment/
│   ├── README.md
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── capstone_portal.py
│   ├── published_artifacts/
│   ├── digitalocean/
│   │   └── app-platform.yaml
│   └── scripts/
├── tests/
│   └── test_module10_planning.py
└── outputs/
```

## ROI Calculation Principle

A credible ROI calculation requires:

1. Investment cost: staff time, licences, infrastructure, and training.
2. Quantified benefit: hours saved, error reduction, reporting cycle time reduction, and risk reduction.
3. Payback period: investment cost divided by monthly benefit.

For Central Bank leadership, present conservative, base-case, and optimistic scenarios, and state assumptions clearly.

## Roadmap Discipline

Use three horizons:

- Horizon 1, 0-6 months: stabilise and optimise existing systems.
- Horizon 2, 6-18 months: extend automation and integration to more data domains.
- Horizon 3, 18-36 months: evaluate emerging technologies against future regulatory and operational needs.

Each horizon must include owners, budget estimates, measurable milestones, and decision checkpoints.

## Run the Tools

From this folder:

```bash
python 01_kpi_roi_calculator.py
python 02_technology_roadmap_builder.py
python 03_prepare_deployment_bundle.py
pytest -q
```

Generated files are written to `outputs/`.

## Deployable Capstone Portal

Module 10 includes a deployable web portal:

```text
deployment/
```

The portal serves the final capstone evidence as a simple web page. It can run:

- locally with Python
- locally with Docker Compose
- on a DigitalOcean Droplet
- on DigitalOcean App Platform using a container image

Start locally:

```bash
python 03_prepare_deployment_bundle.py
cd deployment
python capstone_portal.py
```

Open:

```text
http://localhost:8000
```

Docker:

```bash
cd deployment
docker compose up --build
```

DigitalOcean instructions are in:

```text
deployment/README.md
digitalocean_deployment_plan.md
deployment_option_matrix.md
```
