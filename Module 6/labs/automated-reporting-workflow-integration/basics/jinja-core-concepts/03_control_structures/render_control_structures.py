"""
Lesson 3: Jinja2 control structures.

Learning focus:
Use if/elif/else when the template should display different text depending on
the data.
"""

from pathlib import Path

from jinja2 import Environment, FileSystemLoader


LESSON_DIR = Path(__file__).resolve().parent
ROOT_DIR = LESSON_DIR.parent
OUTPUT_DIR = ROOT_DIR / "outputs"


def main() -> None:
    context = {
        "report_title": "Inflation Risk Classification",
        "high_threshold": 10.0,
        "medium_threshold": 6.0,
        "countries": [
            {"name": "Lesotho", "inflation": 5.2},
            {"name": "South Africa", "inflation": 4.6},
            {"name": "Namibia", "inflation": 6.4},
            {"name": "Zimbabwe", "inflation": 28.4},
        ],
    }

    env = Environment(loader=FileSystemLoader(LESSON_DIR))
    template = env.get_template("control_structures.html.j2")

    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / "03_control_structures.html"
    output_path.write_text(template.render(context), encoding="utf-8")

    print(f"Created: {output_path}")


if __name__ == "__main__":
    main()
