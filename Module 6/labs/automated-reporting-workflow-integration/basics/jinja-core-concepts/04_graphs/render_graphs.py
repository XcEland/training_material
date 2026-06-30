"""
Lesson 4: Jinja2 with graphs.

Learning focus:
Python creates the graph file. Jinja2 places that graph inside the HTML report.

This is a common real-world reporting pattern:
1. Python loads or prepares the data.
2. Python creates chart images.
3. Jinja2 builds a formatted HTML report that includes the charts.
"""

from pathlib import Path

import matplotlib.pyplot as plt
from jinja2 import Environment, FileSystemLoader


LESSON_DIR = Path(__file__).resolve().parent
ROOT_DIR = LESSON_DIR.parent
OUTPUT_DIR = ROOT_DIR / "outputs"
CHARTS_DIR = OUTPUT_DIR / "charts"


def create_inflation_chart(countries: list[dict[str, float | str]]) -> str:
    """Create a simple bar chart and return the relative path for the template."""

    country_names = [country["name"] for country in countries]
    inflation_rates = [country["inflation"] for country in countries]

    CHARTS_DIR.mkdir(parents=True, exist_ok=True)
    chart_path = CHARTS_DIR / "04_inflation_bar_chart.png"

    # Matplotlib creates the chart as an image file.
    plt.figure(figsize=(8, 4.5))
    plt.bar(country_names, inflation_rates, color="#0f766e")
    plt.title("Inflation Rates by Country")
    plt.xlabel("Country")
    plt.ylabel("Inflation rate (%)")
    plt.grid(axis="y", linestyle="--", alpha=0.35)
    plt.tight_layout()
    plt.savefig(chart_path, dpi=150)
    plt.close()

    # The HTML file is saved in outputs/, so the image path starts from there.
    return "charts/04_inflation_bar_chart.png"


def main() -> None:
    countries = [
        {"name": "Lesotho", "inflation": 5.2},
        {"name": "South Africa", "inflation": 4.6},
        {"name": "Namibia", "inflation": 6.4},
        {"name": "Botswana", "inflation": 3.1},
        {"name": "Zimbabwe", "inflation": 28.4},
    ]

    chart_file = create_inflation_chart(countries)

    context = {
        "report_title": "Inflation Chart Report",
        "report_month": "2026-06",
        "countries": countries,
        "chart_file": chart_file,
        "highest_country": max(countries, key=lambda row: row["inflation"]),
    }

    env = Environment(loader=FileSystemLoader(LESSON_DIR))
    template = env.get_template("graphs.html.j2")

    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / "04_graphs.html"
    output_path.write_text(template.render(context), encoding="utf-8")

    print(f"Created: {output_path}")
    print(f"Created chart: {OUTPUT_DIR / chart_file}")


if __name__ == "__main__":
    main()
