"""
Python cProfile Bottleneck Script.
"""

import cProfile
import pstats


def extract_data():
    # Create enough rows for the profiler to measure.
    return list(range(50_000))


def clean_data(raw_rows):
    # This list comprehension will appear in the profile output.
    return [row for row in raw_rows if row % 2 == 0]


def transform_data(clean_rows):
    # This generator is another step the profiler can time.
    return sum(row * 2 for row in clean_rows)


def load_data(summary_value):
    print(summary_value)


def main():
    # Profile the full extract, clean, transform, load flow.
    raw_rows = extract_data()
    clean_rows = clean_data(raw_rows)
    summary_value = transform_data(clean_rows)
    load_data(summary_value)


profiler = cProfile.Profile()

# Enable profiling only around the workflow being measured.
profiler.enable()
main()
profiler.disable()

# Sort by cumulative time to find where time is spent.
stats = pstats.Stats(profiler)
stats.sort_stats("cumtime")
stats.print_stats(10)
