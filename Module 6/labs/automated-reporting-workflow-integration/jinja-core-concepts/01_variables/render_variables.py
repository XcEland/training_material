"""
Lesson 1: Jinja2 variables.

Learning focus:
Python sends values into a template. The template prints those values using
double curly braces: {{ value_name }}.
"""

from pathlib import Path

from jinja2 import Environment, FileSystemLoader


LESSON_DIR = Path(__file__).resolve().parent
ROOT_DIR = LESSON_DIR.parent
OUTPUT_DIR = ROOT_DIR / "outputs"


def main() -> None:
    # This is the data we want to show in the HTML page.
    context = {
        "report_title": "Monthly Inflation Note",
        "report_month": "2026-06",
        "country": "Lesotho",
        "inflation_rate": "5.2%",
        "prepared_by": "Training Analyst",
    }

    env = Environment(loader=FileSystemLoader(LESSON_DIR))
    template = env.get_template("variables.html.j2")

    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / "01_variables.html"
    output_path.write_text(template.render(context), encoding="utf-8")

    print(f"Created: {output_path}")


if __name__ == "__main__":
    main()
