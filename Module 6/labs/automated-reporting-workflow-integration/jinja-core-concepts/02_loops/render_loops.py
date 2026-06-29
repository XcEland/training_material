"""
Lesson 2: Jinja2 loops.

Learning focus:
Use a loop when Python sends a list of rows and the template must repeat the
same HTML for every row.
"""

from pathlib import Path

from jinja2 import Environment, FileSystemLoader


LESSON_DIR = Path(__file__).resolve().parent
ROOT_DIR = LESSON_DIR.parent
OUTPUT_DIR = ROOT_DIR / "outputs"


def main() -> None:
    context = {
        "report_title": "Country Inflation Table",
        "countries": [
            {"name": "Lesotho", "inflation": 5.2},
            {"name": "South Africa", "inflation": 4.6},
            {"name": "Botswana", "inflation": 3.1},
            {"name": "Zimbabwe", "inflation": 28.4},
        ],
    }

    env = Environment(loader=FileSystemLoader(LESSON_DIR))
    template = env.get_template("loops.html.j2")

    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / "02_loops.html"
    output_path.write_text(template.render(context), encoding="utf-8")

    print(f"Created: {output_path}")


if __name__ == "__main__":
    main()
