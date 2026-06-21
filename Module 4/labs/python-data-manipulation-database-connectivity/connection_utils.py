import os
from pathlib import Path
from urllib.parse import quote_plus

import pyodbc
from dotenv import load_dotenv
from sqlalchemy import create_engine


def load_settings(env_file=".env"):
    env_path = Path(__file__).with_name(env_file)
    load_dotenv(env_path)

    return {
        "driver": os.getenv("DB_DRIVER"),
        "server": os.getenv("DB_SERVER"),
        "database": os.getenv("DB_NAME"),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
        "auth": os.getenv("DB_AUTH", "sql").lower(),
        "trusted": os.getenv("DB_TRUSTED", "no").lower() in ("yes", "true", "1"),
        "trust_cert": os.getenv("DB_TRUST_CERT", "yes").lower() in ("yes", "true", "1"),
    }


def build_odbc_connection_string(settings):
    parts = [
        f"DRIVER={{{settings['driver']}}}",
        f"SERVER={settings['server']}",
        f"DATABASE={settings['database']}",
        "Encrypt=yes",
        f"TrustServerCertificate={'yes' if settings['trust_cert'] else 'no'}",
    ]

    if settings["auth"] == "windows" or settings["trusted"]:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([
            f"UID={settings['user']}",
            f"PWD={settings['password']}",
        ])

    return ";".join(parts) + ";"


def get_pyodbc_connection(env_file=".env"):
    settings = load_settings(env_file)
    return pyodbc.connect(build_odbc_connection_string(settings))


def get_sqlalchemy_engine(env_file=".env"):
    settings = load_settings(env_file)
    odbc_connection = build_odbc_connection_string(settings)
    quoted = quote_plus(odbc_connection)
    return create_engine(f"mssql+pyodbc:///?odbc_connect={quoted}", fast_executemany=True)
