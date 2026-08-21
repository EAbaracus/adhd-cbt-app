## 2023-10-25 - [SQLite Executemany Optimization]
**Learning:** SQLite's `executemany` handles batched inserts with `ON CONFLICT` significantly faster than repeatedly invoking `execute` inside a loop in Python.
**Action:** When saving potentially large synchronized structures over REST/sync calls (like lists of forms or JSON sync payloads), use list comprehensions and `executemany` to avoid repeated context switching overhead between DB engine and application loop.
