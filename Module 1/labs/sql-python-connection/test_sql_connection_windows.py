import os
from pathlib import Path

import pyodbc
from dotenv import load_dotenv


env_path = Path(__file__).with_name(".env.windows")
load_dotenv(env_path)

server = os.getenv("DB_SERVER")
database = os.getenv("DB_NAME")
driver = os.getenv("DB_DRIVER")
auth = os.getenv("DB_AUTH", "windows").lower()
trusted = os.getenv("DB_TRUSTED", "yes").lower() in ("yes", "true", "1")
trust_cert = os.getenv("DB_TRUST_CERT", "yes").lower() in ("yes", "true", "1")
username = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")

connection_parts = [
    f"DRIVER={{{driver}}}",
    f"SERVER={server}",
    f"DATABASE={database}",
    "Encrypt=yes",
    f"TrustServerCertificate={'yes' if trust_cert else 'no'}",
]

if auth == "windows" or trusted:
    connection_parts.append("Trusted_Connection=yes")
else:
    connection_parts.extend([
        f"UID={username}",
        f"PWD={password}",
    ])

connection_string = ";".join(connection_parts) + ";"

print("Connecting to:", server)
print("Database:", database)
print("Driver:", driver)
print("Auth:", "Windows Authentication" if auth == "windows" or trusted else "SQL Login")

try:
    conn = pyodbc.connect(connection_string)

    cursor = conn.cursor()
    cursor.execute("SELECT @@VERSION AS version;")
    row = cursor.fetchone()

    print("Python connected successfully!")
    print(row.version)

    print("\nTop 5 customer records:")
    cursor.execute("""
        SELECT TOP 5
            id,
            name,
            country,
            score
        FROM dbo.Customers
        ORDER BY id;
    """)

    print(f"{'id':<4} {'name':<20} {'country':<12} {'score':>5}")
    print("-" * 45)

    for customer in cursor.fetchall():
        print(
            f"{customer.id:<4} "
            f"{customer.name:<20} "
            f"{customer.country:<12} "
            f"{customer.score:>5}"
        )

    cursor.close()
    conn.close()

except Exception as e:
    print("Python connection failed.")
    print(e)
