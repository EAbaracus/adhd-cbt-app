import pytest
from app.auth.store import UserStore
from app.sync.routes import _upsert, _UPSERT_QUERIES
import sqlite3

class DummyConn:
    def executemany(self, query, params):
        self.query = query
        self.params = params
        return DummyCursor()
    def commit(self):
        pass
    def execute(self, q):
        pass

class DummyCursor:
    rowcount = 1

class DummyStore(UserStore):
    def __init__(self):
        self.conn = DummyConn()

def test_upsert_valid_kind():
    store = DummyStore()
    user_id = 1
    items = {"key1": {"payload": {"a": 1}, "updated_at": "2023-01-01"}}

    count = _upsert(store, user_id, "progress", items)

    assert count == 1
    assert store.conn.query == _UPSERT_QUERIES["progress"]

def test_upsert_invalid_kind():
    store = DummyStore()
    user_id = 1
    items = {"key1": {"payload": {"a": 1}, "updated_at": "2023-01-01"}}

    count = _upsert(store, user_id, "invalid_kind", items)

    assert count == 0
