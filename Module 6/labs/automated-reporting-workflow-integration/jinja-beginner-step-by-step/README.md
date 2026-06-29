# Jinja2 Beginner Step-By-Step

This folder is for absolute beginners. Each lesson has:

- one Python file
- one HTML template
- one output HTML file

The goal is to learn one idea at a time.

## Lesson Order

1. `01_variables/` - print values from Python into HTML.
2. `02_loops/` - repeat HTML for every item in a list.
3. `03_control_structures/` - use `if`, `elif`, and `else` to choose what appears.

## Run

From this folder:

```bash
../../../../.venv/bin/python 01_variables/render_variables.py
../../../../.venv/bin/python 02_loops/render_loops.py
../../../../.venv/bin/python 03_control_structures/render_control_structures.py
```

Open the generated files:

```text
outputs/01_variables.html
outputs/02_loops.html
outputs/03_control_structures.html
```

## Beginner Rule

Python prepares the data. Jinja2 controls how the data appears in the report.
