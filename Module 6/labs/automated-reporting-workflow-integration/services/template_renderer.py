"""Shared Jinja2 rendering service."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, select_autoescape


def build_environment(template_dir: Path) -> Environment:
    return Environment(
        loader=FileSystemLoader(template_dir),
        autoescape=select_autoescape(["html", "xml"]),
    )


def render_template(template_dir: Path, template_name: str, output_path: Path, context: dict[str, Any]) -> Path:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    env = build_environment(template_dir)
    template = env.get_template(template_name)
    output_path.write_text(template.render(**context), encoding="utf-8")
    return output_path
