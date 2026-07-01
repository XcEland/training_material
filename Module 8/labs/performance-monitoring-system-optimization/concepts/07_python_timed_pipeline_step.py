"""
Python Timed Pipeline Step.

Use this to measure how long each ETL pipeline step takes.
"""

import logging
import time


logging.basicConfig(level=logging.INFO, format="%(levelname)s - %(message)s")


def timed_step(step_name, function, *args, **kwargs):
    # step_name is the label printed in the log.
    # function is the pipeline step being measured.
    # Start the timer before the workflow step runs.
    start = time.perf_counter()

    logging.info(f"{step_name}: started")

    # Run the function passed into this helper.
    result = function(*args, **kwargs)

    # Measure the elapsed time after the function finishes.
    duration = time.perf_counter() - start

    logging.info(f"{step_name}: completed in {duration:.2f} seconds")

    return result


def extract_data():
    # Small sample data for the demo.
    return [10, 20, 30]


def clean_data(rows):
    # Keep only rows that pass the simple rule.
    return [row for row in rows if row > 10]


def transform_data(rows):
    # Summarise the cleaned rows.
    return sum(rows)


# Each pipeline stage is wrapped with timed_step.
raw_rows = timed_step("Extract Data", extract_data)
clean_rows = timed_step("Clean Data", clean_data, raw_rows)
summary_value = timed_step("Transform Data", transform_data, clean_rows)

print(summary_value)
