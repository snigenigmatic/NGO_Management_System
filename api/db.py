import os
from dotenv import load_dotenv
import mysql.connector
from contextlib import contextmanager

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "ngo_management"),
}


@contextmanager
def get_conn():
    # Basic sanity checks to provide a friendly error when .env is missing
    if (
        not DB_CONFIG.get("user")
        or DB_CONFIG.get("user") == "root"
        and DB_CONFIG.get("password", "") == ""
    ):
        # Avoid leaking passwords; give actionable instructions instead
        raise RuntimeError(
            "Database credentials appear missing or empty.\n"
            "Create a file named `.env` in the `api/` folder (copy `.env.example`) and set DB_USER and DB_PASSWORD,\n"
            "or set the environment variables DB_USER and DB_PASSWORD for the process.\n"
            "Then restart the FastAPI server."
        )

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
    except mysql.connector.Error as e:
        # Wrap connector errors to make logs easier to read in the server output
        raise RuntimeError(f"Unable to connect to MySQL: {e}") from e

    try:
        yield conn
    finally:
        conn.close()


def fetchall(sql: str, params=None):
    with get_conn() as conn:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or [])
        rows = cur.fetchall()
        cur.close()
        return rows


def execute(sql: str, params=None):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(sql, params or [])
        conn.commit()
        cur.close()


def callproc(proc_name: str, params: list):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.callproc(proc_name, params)
        conn.commit()
        cur.close()
        return None
