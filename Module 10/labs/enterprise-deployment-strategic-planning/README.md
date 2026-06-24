# Enterprise Deployment and Strategic Planning

This Module 10 lab turns technical implementation into a leadership-ready proposal. It is designed for the final day of the programme: students quantify benefits, plan deployment gates, define adoption actions, build a roadmap, and defend design choices in a simulated executive panel.

## Learning Order

1. Complete `deployment_plan_template.md`.
2. Run `01_roi_kpi_calculator.py` to calculate conservative, base-case, and optimistic ROI scenarios.
3. Review `02_technology_roadmap_builder.py` and update the roadmap input file.
4. Complete `strategic_technology_roadmap_template.md`.
5. Complete `user_training_adoption_plan.md`.
6. Use `capstone_executive_proposal_template.md` for the final presentation.
7. Use `peer_assessment_rubric.md` during panel review.
8. Run the tests.

## Files

```text
Module 10/labs/enterprise-deployment-strategic-planning/
├── README.md
├── 01_roi_kpi_calculator.py
├── 02_technology_roadmap_builder.py
├── deployment_plan_template.md
├── change_management_release_checklist.md
├── user_training_adoption_plan.md
├── strategic_technology_roadmap_template.md
├── capstone_executive_proposal_template.md
├── peer_assessment_rubric.md
├── executive_panel_question_bank.md
├── config/
│   ├── roi_scenarios.json
│   └── roadmap_options.json
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
python 01_roi_kpi_calculator.py
python 02_technology_roadmap_builder.py
pytest -q
```

Generated files are written to `outputs/`.
