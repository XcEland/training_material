"""
Shared SQL Server helpers for Module 8.
"""

from __future__ import annotations

import os
import socket
from pathlib import Path
from urllib.parse import quote_plus

from dotenv import load_dotenv
from sqlalchemy import create_engine


LAB_DIR = Path(__file__).resolve().parent
REPO_ROOT = LAB_DIR.parents[2]


def load_environment(env_file: str = ".env") -> None:
    candidates = [
        LAB_DIR / env_file,
        REPO_ROOT / env_file,
        REPO_ROOT / "Module 7" / "labs" / "api-integration-external-data-sources" / env_file,
        REPO_ROOT / "Module 6" / "labs" / "automated-reporting-workflow-integration" / env_file,
        REPO_ROOT / "Module 4" / "labs" / "python-data-manipulation-database-connectivity" / env_file,
        REPO_ROOT / "Module 1" / "labs" / "sql-python-connection" / env_file,
    ]

    for env_path in candidates:
        if env_path.exists():
            load_dotenv(env_path)
            return


def build_odbc_connection_string() -> str:
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("DB_SERVER", "localhost,1433")
    database = os.getenv("DB_NAME", "TrainingDB")
    user = os.getenv("DB_USER", "sa")
    password = os.getenv("DB_PASSWORD", "")
    trusted = os.getenv("DB_TRUSTED", "no").lower() in ("yes", "true", "1")

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        "Encrypt=yes",
        "TrustServerCertificate=yes",
        "Connection Timeout=2",
    ]
    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={user}", f"PWD={password}"])
    return ";".join(parts) + ";"


def sql_server_endpoint() -> tuple[str, int] | None:
    """Return a host and port for a quick SQL Server reachability check."""
    server = os.getenv("DB_SERVER", "localhost,1433").replace("tcp:", "")
    if "\\" in server:
        return None

    if "," in server:
        host, port_text = server.rsplit(",", 1)
    elif ":" in server:
        host, port_text = server.rsplit(":", 1)
    else:
        host, port_text = server, "1433"

    try:
        return host.strip(), int(port_text.strip())
    except ValueError:
        return None


def can_reach_sql_server(timeout_seconds: float = 0.75) -> bool:
    """Avoid slow ODBC login attempts when SQL Server is not reachable."""
    endpoint = sql_server_endpoint()
    if endpoint is None:
        return True

    host, port = endpoint
    try:
        with socket.create_connection((host, port), timeout=timeout_seconds):
            return True
    except OSError:
        return False


def get_sqlalchemy_engine(env_file: str = ".env"):
    load_environment(env_file)
    quoted = quote_plus(build_odbc_connection_string())
    return create_engine(f"mssql+pyodbc:///?odbc_connect={quoted}", fast_executemany=True)
