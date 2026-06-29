"""SQL Server connection helpers shared by all reports."""

from __future__ import annotations

import os
from urllib.parse import quote_plus

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


def build_sqlalchemy_engine() -> Engine:
    """Build a SQLAlchemy engine from environment variables."""
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("DB_SERVER", "localhost,1433")
    database = os.getenv("DB_NAME", "TrainingDB")
    user = os.getenv("DB_USER", "sa")
    password = os.getenv("DB_PASSWORD", "StrongPassw0rd!2026")
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

    connection_string = ";".join(parts) + ";"
    return create_engine(f"mssql+pyodbc:///?odbc_connect={quote_plus(connection_string)}")


def try_connect() -> Engine | None:
    """Return a working SQLAlchemy engine, or None for Excel fallback mode."""
    try:
        engine = build_sqlalchemy_engine()
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return engine
    except Exception as exc:
        print("SQL Server unavailable. Reports will use Excel fallback data:", exc)
        return None
