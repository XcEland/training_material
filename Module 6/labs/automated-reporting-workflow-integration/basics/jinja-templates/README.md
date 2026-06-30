# Jinja2 Basics Mini-Lab

This mini-lab teaches Jinja2 before you inspect the larger Module 6 report templates.

Jinja2 is a template engine. In this course, Python prepares data and Jinja2 turns that data into formatted text or HTML reports.

## Learning Order

1. Run the Python renderer.
2. Open the generated files in `outputs/`.
3. Compare each output with its template in `templates/`.
4. Then inspect the production templates in `../templates/reports/` and `../templates/emails/`.

## Files

```text
jinja-basics/
├── README.md
├── 01_render_jinja_basics.py
├── templates/
│   ├── 01_variables.txt.j2
│   ├── 02_loops_and_conditionals.txt.j2
│   ├── 03_base_report.html.j2
│   ├── 04_mini_macro_report.html.j2
│   └── _metric_card.html.j2
└── outputs/
```

## Run

From this folder:

```bash
../../../../.venv/bin/python 01_render_jinja_basics.py
```

Or, from the Module 6 lab folder:

```bash
../../../.venv/bin/python jinja-basics/01_render_jinja_basics.py
```

## What Learners Should Notice

- `{{ variable }}` prints a value.
- `{% for item in items %}` repeats content.
- `{% if condition %}` controls whether content appears.
- `{% include "file.html.j2" %}` reuses a small template.
- `{% extends "base.html.j2" %}` lets many reports share one layout.
- Python passes the context dictionary into the template.

## Expected Outputs

```text
outputs/01_variables_output.txt
outputs/02_loops_and_conditionals_output.txt
outputs/04_mini_macro_report.html
```

Open the HTML file in a browser to see how a simple Jinja2 template becomes a professional report page.
