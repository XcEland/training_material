"""Configuration helpers for the Module 6 reporting lab."""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

from dotenv import load_dotenv


LAB_DIR = Path(__file__).resolve().parents[1]
REPO_ROOT = LAB_DIR.parents[2]
DEFAULT_CONFIG = LAB_DIR / "config" / "reporting_config.json"


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def load_settings(config_path: str | Path = DEFAULT_CONFIG, env_file: str = ".env") -> dict[str, Any]:
    """Load JSON settings and environment variables.

    Environment variables stay separate from JSON config because passwords,
    SMTP credentials, and deployment-specific paths should not be committed.
    """
    env_path = LAB_DIR / env_file
    if env_path.exists():
        load_dotenv(env_path)
    else:
        print(f"Environment file not found: {env_path}. Using process environment and defaults.")

    config = load_json(Path(config_path))
    config["paths"] = {
        "lab_dir": LAB_DIR,
        "repo_root": REPO_ROOT,
        "outputs": LAB_DIR / "outputs",
        "html": LAB_DIR / "outputs" / "html",
        "pdf": LAB_DIR / "outputs" / "pdf",
        "email": LAB_DIR / "outputs" / "email",
        "data": LAB_DIR / "outputs" / "data",
        "templates": LAB_DIR / "templates",
    }
    return config


def env_bool(name: str, default: bool = False) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    return value.lower() in ("1", "true", "yes", "y")


def resolve_lab_path(path_text: str) -> Path:
    """Resolve config paths relative to the lab folder."""
    path = Path(path_text)
    if path.is_absolute():
        return path
    return (LAB_DIR / path).resolve()
