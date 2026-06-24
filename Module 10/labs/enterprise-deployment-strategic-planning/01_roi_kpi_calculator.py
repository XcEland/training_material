"""
Module 10: KPI and ROI calculator.

The goal is not to produce a perfect financial model. The goal is to help
students explain database programming investments in leadership language:
- How much does the initiative cost?
- How much measurable benefit does it create each month?
- How long until the investment pays back?
- What is the annual ROI?
"""

from __future__ import annotations

import json
from dataclasses import dataclass, asdict
from pathlib import Path


CONFIG_PATH = Path("config/roi_scenarios.json")
OUTPUT_PATH = Path("outputs/roi_summary.json")


@dataclass(frozen=True)
class RoiScenario:
    name: str
    investment_cost: float
    monthly_hours_saved: float
    staff_hourly_cost: float
    monthly_errors_avoided: float
    cost_per_error: float
    monthly_operating_cost: float


@dataclass(frozen=True)
class RoiResult:
    name: str
    monthly_time_saving_value: float
    monthly_error_reduction_value: float
    monthly_gross_benefit: float
    monthly_net_benefit: float
    annual_net_benefit: float
    payback_months: float | None
    roi_percent: float


def calculate_roi(scenario: RoiScenario) -> RoiResult:
    """Calculate ROI using simple, explainable assumptions."""

    monthly_time_saving_value = scenario.monthly_hours_saved * scenario.staff_hourly_cost
    monthly_error_reduction_value = scenario.monthly_errors_avoided * scenario.cost_per_error
    monthly_gross_benefit = monthly_time_saving_value + monthly_error_reduction_value
    monthly_net_benefit = monthly_gross_benefit - scenario.monthly_operating_cost
    annual_net_benefit = monthly_net_benefit * 12

    if monthly_net_benefit > 0:
        payback_months = scenario.investment_cost / monthly_net_benefit
    else:
        payback_months = None

    roi_percent = ((annual_net_benefit - scenario.investment_cost) / scenario.investment_cost) * 100

    return RoiResult(
        name=scenario.name,
        monthly_time_saving_value=round(monthly_time_saving_value, 2),
        monthly_error_reduction_value=round(monthly_error_reduction_value, 2),
        monthly_gross_benefit=round(monthly_gross_benefit, 2),
        monthly_net_benefit=round(monthly_net_benefit, 2),
        annual_net_benefit=round(annual_net_benefit, 2),
        payback_months=None if payback_months is None else round(payback_months, 2),
        roi_percent=round(roi_percent, 2),
    )


def load_scenarios(path: Path = CONFIG_PATH) -> list[RoiScenario]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return [RoiScenario(**item) for item in data["scenarios"]]


def write_results(results: list[RoiResult], output_path: Path = OUTPUT_PATH) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps([asdict(result) for result in results], indent=2),
        encoding="utf-8",
    )


def main() -> None:
    scenarios = load_scenarios()
    results = [calculate_roi(scenario) for scenario in scenarios]
    write_results(results)

    print("ROI Summary")
    for result in results:
        print(
            f"- {result.name}: monthly net benefit={result.monthly_net_benefit}, "
            f"payback={result.payback_months} months, ROI={result.roi_percent}%"
        )
    print(f"Report written to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
