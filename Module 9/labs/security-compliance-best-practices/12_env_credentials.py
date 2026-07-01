"""Build a SQL Server engine from environment variables."""

import os
from urllib.parse import quote_plus

from dotenv import load_dotenv
from sqlalchemy import create_engine


load_dotenv()

def build_odbc_connection_string() -> str:
    """Use the same TrainingDB connection pattern as Modules 7 and 8."""
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("DB_SERVER", "localhost,1433")
    database = os.getenv("DB_NAME", "TrainingDB")
    user = os.getenv("DB_USER", "")
    password = os.getenv("DB_PASSWORD", "")
    encrypt = os.getenv("DB_ENCRYPT", "yes")
    trust_cert = os.getenv("DB_TRUST_SERVER_CERTIFICATE", "yes")
    trusted = os.getenv("DB_TRUSTED", "no").lower() in {"yes", "true", "1"}

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        f"Encrypt={encrypt}",
        f"TrustServerCertificate={trust_cert}",
        "Connection Timeout=5",
    ]

    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={user}", f"PWD={password}"])

    return ";".join(parts) + ";"


def create_trainingdb_engine():
    """Return an engine without placing passwords in source code."""
    params = quote_plus(build_odbc_connection_string())
    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}", fast_executemany=True)


if __name__ == "__main__":
    engine = create_trainingdb_engine()
    print("Engine created for TrainingDB without hardcoded credentials.")
