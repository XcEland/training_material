import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

server = os.getenv("DB_SERVER")
database = os.getenv("DB_NAME")
username = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")
driver = os.getenv("DB_DRIVER")

connection_string = (
    f"DRIVER={{{driver}}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)

print("Connecting to:", server)
print("Database:", database)
print("Driver:", driver)

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
