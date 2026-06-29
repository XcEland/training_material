"""
Module 10: Strategic technology roadmap builder.

Each option receives a simple priority score:
business value + security value + risk reduction - implementation effort.

This keeps the exercise transparent while comparing strategic options using
measurable criteria.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, asdict
from pathlib import Path


CONFIG_PATH = Path("config/roadmap_options.json")
OUTPUT_PATH = Path("outputs/roadmap_priorities.json")


@dataclass(frozen=True)
class RoadmapOption:
    name: str
    horizon: str
    owner: str
    estimated_budget: float
    business_value: int
    security_value: int
    implementation_effort: int
    risk_reduction: int
    milestone: str


@dataclass(frozen=True)
class RoadmapPriority:
    name: str
    horizon: str
    owner: str
    estimated_budget: float
    milestone: str
    priority_score: int


def score_option(option: RoadmapOption) -> int:
    """Higher score means stronger candidate for earlier delivery."""

    return (
        option.business_value
        + option.security_value
        + option.risk_reduction
        - option.implementation_effort
    )


def build_priorities(options: list[RoadmapOption]) -> list[RoadmapPriority]:
    priorities = [
        RoadmapPriority(
            name=option.name,
            horizon=option.horizon,
            owner=option.owner,
            estimated_budget=option.estimated_budget,
            milestone=option.milestone,
            priority_score=score_option(option),
        )
        for option in options
    ]
    return sorted(priorities, key=lambda item: (item.horizon, -item.priority_score, item.name))


def load_options(path: Path = CONFIG_PATH) -> list[RoadmapOption]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return [RoadmapOption(**item) for item in data["options"]]


def write_priorities(priorities: list[RoadmapPriority], output_path: Path = OUTPUT_PATH) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps([asdict(priority) for priority in priorities], indent=2),
        encoding="utf-8",
    )


def main() -> None:
    priorities = build_priorities(load_options())
    write_priorities(priorities)

    print("Roadmap Priorities")
    for priority in priorities:
        print(f"- {priority.horizon}: {priority.name} ({priority.priority_score})")
    print(f"Report written to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
