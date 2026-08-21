## 2023-10-25 - [Batching SQLite inserts with executemany in Python]
**Learning:** Python's `sqlite3` driver accurately returns `cur.rowcount` on `executemany` with `INSERT ... ON CONFLICT DO UPDATE` queries. This allows us to safely optimize N+1 loops where we process dictionary items, avoiding both SQLite parsing overhead and Python-side loop penalties.
**Action:** Always look for iterative `execute()` statements in the backend and replace them with `executemany()`, checking for empty sequences beforehand to avoid issues.
