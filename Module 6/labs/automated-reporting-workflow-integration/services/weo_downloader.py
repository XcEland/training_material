"""Resolve, optionally download, and track WEO workbook release metadata."""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

import requests

from config.settings import resolve_lab_path


def resolve_weo_workbook(config: dict[str, Any], force_download: bool = False) -> tuple[Path, dict[str, Any]]:
    weo_config = config["weo_dataset"]
    local_path = resolve_lab_path(os.getenv("WEO_LOCAL_WORKBOOK", weo_config["local_workbook_path"]))
    download_url = os.getenv("WEO_DOWNLOAD_URL", weo_config.get("download_url", "")).strip()
    data_dir = config["paths"]["data"]
    data_dir.mkdir(parents=True, exist_ok=True)

    if download_url and force_download:
        target_path = data_dir / "WEO_latest.xlsx"
        response = requests.get(download_url, timeout=60)
        response.raise_for_status()
        target_path.write_bytes(response.content)
        return target_path, {"download_status": "Downloaded", "download_url": download_url}

    if local_path.exists():
        return local_path, {"download_status": "UsingLocalWorkbook", "download_url": download_url or "not configured"}

    if download_url:
        target_path = data_dir / "WEO_latest.xlsx"
        response = requests.get(download_url, timeout=60)
        response.raise_for_status()
        target_path.write_bytes(response.content)
        return target_path, {"download_status": "Downloaded", "download_url": download_url}

    raise FileNotFoundError(f"WEO workbook not found: {local_path}")


def update_release_manifest(config: dict[str, Any], metadata: dict[str, Any]) -> dict[str, Any]:
    """Record whether the workbook publication date changed since the last run."""
    manifest_path = config["paths"]["data"] / "weo_release_manifest.json"
    previous: dict[str, Any] = {}
    if manifest_path.exists():
        previous = json.loads(manifest_path.read_text(encoding="utf-8"))

    current = {
        "publication_date": metadata.get("publication_date", "unknown"),
        "source_workbook": metadata.get("source_workbook", ""),
    }
    changed = previous.get("publication_date") != current["publication_date"]
    manifest_path.write_text(json.dumps(current, indent=2), encoding="utf-8")

    return {
        "manifest_path": str(manifest_path),
        "previous_publication_date": previous.get("publication_date"),
        "current_publication_date": current["publication_date"],
        "release_changed_since_last_run": changed,
    }
