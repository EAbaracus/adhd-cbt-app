"""SQLite connection helper. row_factory=Row, FK enforcement on."""
import os
import sqlite3


def get_conn(path: str) -> sqlite3.Connection:
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)
    # check_same_thread=False: FastAPI serves requests on a thread pool; the
    # single connection is shared. SQLite serializes writes with its own
    # locking; single-writer dev setup (F2) keeps this safe.
    conn = sqlite3.connect(path, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn
