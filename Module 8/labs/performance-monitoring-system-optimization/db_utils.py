"""
Shared SQL Server helpers for Module 8.
"""

from __future__ import annotations

import os
from pathlib import Path
from urllib.parse import quote_plus

from dotenv import load_dotenv
from sqlalchemy import create_engine


LAB_DIR = Path(__file__).resolve().parent


def load_environment(env_file: str = ".env") -> None:
    env_path = LAB_DIR / env_file
    if env_path.exists():
        load_dotenv(env_path)


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
        "Connection Timeout=5",
    ]
    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={user}", f"PWD={password}"])
    return ";".join(parts) + ";"


def get_sqlalchemy_engine(env_file: str = ".env"):
    load_environment(env_file)
    quoted = quote_plus(build_odbc_connection_string())
    return create_engine(f"mssql+pyodbc:///?odbc_connect={quoted}", fast_executemany=True)
