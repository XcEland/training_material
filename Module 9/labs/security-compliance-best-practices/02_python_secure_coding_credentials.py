"""
Module 9: Python credential management and secure coding basics.

This script demonstrates three beginner-friendly practices:
1. Read credentials from environment variables, not hardcoded strings.
2. Redact secrets before printing or logging configuration.
3. Validate security settings before a database script runs.
"""

from __future__ import annotations

import os
import json
from dataclasses import dataclass
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"


@dataclass(frozen=True)
class DatabaseSettings:
    """Small container for database connection settings."""

    server: str
    database: str
    username: str | None
    password: str | None
    driver: str
    encrypt: str
    trust_server_certificate: str


def load_database_settings() -> DatabaseSettings:
    """Load settings from environment variables with classroom-safe defaults."""

    return DatabaseSettings(
        server=os.getenv("DB_SERVER", "localhost,1433"),
        database=os.getenv("DB_NAME", "TrainingDB"),
        username=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        driver=os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server"),
        encrypt=os.getenv("DB_ENCRYPT", "yes"),
        trust_server_certificate=os.getenv("DB_TRUST_SERVER_CERTIFICATE", "yes"),
    )


def redact_secret(value: str | None) -> str:
    """Hide secret values before they reach logs or terminal output."""

    if not value:
        return "<not set>"
    if len(value) <= 4:
        return "****"
    return f"{value[:2]}{'*' * (len(value) - 4)}{value[-2:]}"


def describe_settings(settings: DatabaseSettings) -> dict[str, str]:
    """Return a safe-to-print view of connection settings."""

    return {
        "server": settings.server,
        "database": settings.database,
        "username": settings.username or "<integrated/security token>",
        "password": redact_secret(settings.password),
        "driver": settings.driver,
        "encrypt": settings.encrypt,
        "trust_server_certificate": settings.trust_server_certificate,
    }


def validate_security_posture(settings: DatabaseSettings) -> list[str]:
    """Return warnings for settings that would need attention in production."""

    warnings: list[str] = []

    if settings.username and not settings.password:
        warnings.append("DB_USER is set but DB_PASSWORD is missing.")

    if settings.encrypt.lower() != "yes":
        warnings.append("DB_ENCRYPT should be 'yes' for database connections.")

    if settings.trust_server_certificate.lower() == "yes":
        warnings.append(
            "DB_TRUST_SERVER_CERTIFICATE=yes is acceptable for local labs, "
            "but production should validate certificates."
        )

    if settings.username and settings.username.lower() in {"sa", "admin", "administrator"}:
        warnings.append("Avoid privileged database accounts for application scripts.")

    return warnings


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    settings = load_database_settings()
    safe_settings = describe_settings(settings)
    warnings = validate_security_posture(settings)
    review = {
        "safe_settings": safe_settings,
        "warning_count": len(warnings),
        "warnings": warnings,
        "production_rule": "Use environment variables or a secret manager; never hardcode database passwords in Python scripts.",
    }

    print("Safe connection settings for review:")
    for key, value in safe_settings.items():
        print(f"- {key}: {value}")

    print("\nSecurity posture checks:")
    if warnings:
        for warning in warnings:
            print(f"- WARNING: {warning}")
    else:
        print("- No warnings found.")

    output_path = OUTPUT_DIR / "python_security_posture_review.json"
    output_path.write_text(json.dumps(review, indent=2), encoding="utf-8")
    print(f"\nReview written to: {output_path}")


if __name__ == "__main__":
    main()
