from pathlib import Path
import importlib.util
import sys


ROOT = Path(__file__).resolve().parents[1]


def load_module(name: str, filename: str):
    path = ROOT / filename
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


roi = load_module("roi_calculator", "01_roi_kpi_calculator.py")
roadmap = load_module("roadmap_builder", "02_technology_roadmap_builder.py")


def test_roi_calculation_returns_positive_payback():
    scenario = roi.RoiScenario(
        name="test",
        investment_cost=10000,
        monthly_hours_saved=100,
        staff_hourly_cost=30,
        monthly_errors_avoided=10,
        cost_per_error=100,
        monthly_operating_cost=500,
    )

    result = roi.calculate_roi(scenario)

    assert result.monthly_net_benefit == 3500
    assert result.payback_months == 2.86
    assert result.roi_percent > 0


def test_roadmap_score_rewards_value_and_penalises_effort():
    option = roadmap.RoadmapOption(
        name="test",
        horizon="Horizon 1: 0-6 months",
        owner="owner",
        estimated_budget=1000,
        business_value=5,
        security_value=4,
        implementation_effort=2,
        risk_reduction=5,
        milestone="done",
    )

    assert roadmap.score_option(option) == 12


def test_roadmap_priorities_sort_within_horizon():
    lower = roadmap.RoadmapOption("B", "Horizon 1: 0-6 months", "owner", 100, 3, 3, 3, 3, "m")
    higher = roadmap.RoadmapOption("A", "Horizon 1: 0-6 months", "owner", 100, 5, 5, 1, 5, "m")

    priorities = roadmap.build_priorities([lower, higher])

    assert priorities[0].name == "A"
