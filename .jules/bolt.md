## 2023-10-27 - Batch Sync Optimization
**Learning:** Using `sqlite3` `execute()` in a loop creates an N+1 problem that causes significant overhead. The `sqlite3.Cursor` supports `executemany()` even with `ON CONFLICT DO UPDATE` queries. It correctly accumulates total modified rows in `cursor.rowcount`.
**Action:** Use `executemany()` to batch DB insertions where possible instead of a Python `for` loop executing singular queries.
