"""
Beginner Jinja2 rendering examples.

This script is intentionally small and heavily commented. It shows the same
ideas used by the full Module 6 reporting pipeline:
- Python prepares report data.
- Jinja2 templates format that data.
- The rendered output is written to text or HTML files.
"""

from __future__ import annotations

from pathlib import Path

from jinja2 import Environment, FileSystemLoader, select_autoescape


LAB_DIR = Path(__file__).resolve().parent
TEMPLATE_DIR = LAB_DIR / "templates"
OUTPUT_DIR = LAB_DIR / "outputs"


def build_environment() -> Environment:
    """Create the Jinja2 template environment."""
    return Environment(
        loader=FileSystemLoader(TEMPLATE_DIR),
        autoescape=select_autoescape(["html", "xml"]),
    )


def render_to_file(env: Environment, template_name: str, output_name: str, context: dict) -> Path:
    """Render one template using a context dictionary."""
    template = env.get_template(template_name)
    output_path = OUTPUT_DIR / output_name
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(template.render(**context), encoding="utf-8")
    return output_path


def build_context() -> dict:
    """
    Build small sample data for a Central Bank-style macro report.

    In the full reporting pipeline, this data comes from the WEO workbook or SQL
    Server. Here we hard-code a few rows so the Jinja2 syntax is easy to learn.
    """
    return {
        "central_bank_name": "Central Bank Training Simulation",
        "report_title": "Mini Macro Outlook Report",
        "report_month": "2026-06",
        "analyst_name": "Training Analyst",
        "summary_points": [
            "World GDP growth is projected at 3.1 percent.",
            "Sub-Saharan Africa growth is projected above the global average.",
            "Inflation monitoring remains important for policy communication.",
        ],
        "metrics": [
            {"label": "World GDP Growth", "value": "3.1%", "status": "Normal"},
            {"label": "Average Inflation", "value": "7.5%", "status": "Watch"},
            {"label": "High Inflation Countries", "value": "20", "status": "Review"},
        ],
        "countries": [
            {"name": "Lesotho", "inflation": 5.2, "risk_level": "Normal"},
            {"name": "South Africa", "inflation": 4.6, "risk_level": "Normal"},
            {"name": "Zimbabwe", "inflation": 28.4, "risk_level": "High"},
        ],
        "high_inflation_threshold": 10.0,
    }


def main() -> None:
    env = build_environment()
    context = build_context()

    rendered_files = [
        render_to_file(env, "01_variables.txt.j2", "01_variables_output.txt", context),
        render_to_file(env, "02_loops_and_conditionals.txt.j2", "02_loops_and_conditionals_output.txt", context),
        render_to_file(env, "04_mini_macro_report.html.j2", "04_mini_macro_report.html", context),
    ]

    print("Rendered Jinja2 basics outputs:")
    for path in rendered_files:
        print(f"- {path}")


if __name__ == "__main__":
    main()
