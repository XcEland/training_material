"""Static chart images used by PDF report output."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


CHART_COLORS = [
    "#0f766e",
    "#2563eb",
    "#7c3aed",
    "#d97706",
    "#dc2626",
    "#475569",
    "#059669",
    "#9333ea",
]


def chart_paths(config: dict[str, Any], filename: str) -> tuple[Path, str]:
    """Return the disk path and HTML-relative path for one chart image."""

    chart_dir = config["paths"]["outputs"] / "charts"
    chart_dir.mkdir(parents=True, exist_ok=True)
    return chart_dir / filename, f"../charts/{filename}"


def save_line_chart(
    labels: list[int | str],
    datasets: list[dict[str, Any]],
    title: str,
    y_label: str,
    output_path: Path,
) -> None:
    """Save a line chart image for PDF rendering."""

    plt.figure(figsize=(8, 4.4))
    for index, dataset in enumerate(datasets):
        values = [None if value is None else float(value) for value in dataset["data"]]
        plt.plot(
            labels,
            values,
            marker="o",
            linewidth=2,
            markersize=3,
            label=dataset["label"],
            color=CHART_COLORS[index % len(CHART_COLORS)],
        )

    plt.title(title)
    plt.xlabel("Year")
    plt.ylabel(y_label)
    plt.grid(axis="y", linestyle="--", alpha=0.3)
    plt.legend(fontsize=8)
    plt.tight_layout()
    plt.savefig(output_path, dpi=160)
    plt.close()


def save_bar_chart(
    labels: list[str],
    values: list[float | int],
    title: str,
    value_label: str,
    output_path: Path,
    horizontal: bool = False,
) -> None:
    """Save a bar chart image for PDF rendering."""

    plt.figure(figsize=(8, 4.8))
    clean_values = [float(value) for value in values]

    if horizontal:
        positions = range(len(labels))
        plt.barh(positions, clean_values, color="#0f766e")
        plt.yticks(positions, labels, fontsize=7)
        plt.xlabel(value_label)
    else:
        plt.bar(labels, clean_values, color="#0f766e")
        plt.ylabel(value_label)
        plt.xticks(rotation=25, ha="right")

    plt.title(title)
    plt.grid(axis="x" if horizontal else "y", linestyle="--", alpha=0.3)
    plt.tight_layout()
    plt.savefig(output_path, dpi=160)
    plt.close()


def save_scatter_chart(
    datasets: list[dict[str, Any]],
    title: str,
    x_label: str,
    y_label: str,
    output_path: Path,
) -> None:
    """Save a scatter chart image for PDF rendering."""

    plt.figure(figsize=(8, 4.8))
    for index, dataset in enumerate(datasets):
        points = dataset.get("data", [])
        x_values = [float(point["x"]) for point in points]
        y_values = [float(point["y"]) for point in points]
        if not x_values:
            continue
        plt.scatter(
            x_values,
            y_values,
            s=18,
            alpha=0.75,
            label=dataset.get("label", "Series"),
            color=CHART_COLORS[index % len(CHART_COLORS)],
        )

    plt.title(title)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.grid(True, linestyle="--", alpha=0.3)
    plt.legend(fontsize=7)
    plt.tight_layout()
    plt.savefig(output_path, dpi=160)
    plt.close()
