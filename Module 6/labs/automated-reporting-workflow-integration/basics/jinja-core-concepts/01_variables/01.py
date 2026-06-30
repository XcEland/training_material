from pathlib import Path
from jinja2 import Environment, FileSystemLoader

LESSON_DIR = Path(__file__).resolve().parent
ROOT_DIR = LESSON_DIR.parent
OUTPUT_DIR = ROOT_DIR / "outputs"

env = Environment(loader=FileSystemLoader(LESSON_DIR/"templates"))
template = env.get_template('test.html.j2')

context = {
    'report_title':'Inflation Report',
    'report_month': 'June',
    'country': 'Lesotho',
    'inflation_rate': 25.5,
    'prepared_by': 'Andrew Mpofu'
}

context2 = {
    'report_title':'Inflation Report',
    'report_month': 'July',
    'country': 'SA',
    'inflation_rate': 30.5,
    'prepared_by': 'Andrew Mpofu'
}

report = template.render(context)

OUTPUT_DIR.mkdir(exist_ok=True)
output_path = OUTPUT_DIR / "01_variables.html"
output_path.write_text(template.render(context), encoding="utf-8")

print(f"Created: {output_path}")

