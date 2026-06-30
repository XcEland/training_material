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
4. `04_graphs/` - create a graph in Python and place it inside a Jinja2 report.

## Run

From this folder:

```bash
../../../../.venv/bin/python 01_variables/render_variables.py
../../../../.venv/bin/python 02_loops/render_loops.py
../../../../.venv/bin/python 03_control_structures/render_control_structures.py
../../../../.venv/bin/python 04_graphs/render_graphs.py
```

If your virtual environment is already active and you are inside one lesson
folder, run the Python file directly. For example, from `04_graphs/`:

```bash
python render_graphs.py
```

If your virtual environment is not active and you are inside `04_graphs/`, use:

```bash
../../../../../.venv/bin/python render_graphs.py
```

Open the generated files:

```text
outputs/01_variables.html
outputs/02_loops.html
outputs/03_control_structures.html
outputs/04_graphs.html
outputs/charts/04_inflation_bar_chart.png
```

## Beginner Rule

Python prepares the data and creates graph files. Jinja2 controls how the data
and graph files appear in the report.
