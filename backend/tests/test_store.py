import pytest
from app.auth import store as S


@pytest.fixture
def store(tmp_path):
    from app.db import get_conn
    conn = get_conn(str(tmp_path / "users.db"))
    st = S.UserStore(conn)
    st.init_schema()
    yield st
    conn.close()


def test_create_and_fetch(store):
    u = store.create_user("a@b.com", "hash1", "TR", 18, True)
    got = store.get_user_by_email("a@b.com")
    assert got["id"] == u["id"]
    assert got["email"] == "a@b.com"
    assert "password_hash" not in store.get_public_user(got)


def test_duplicate_email_raises(store):
    store.create_user("a@b.com", "h", "TR", 18, True)
    with pytest.raises(S.DuplicateEmailError):
        store.create_user("a@b.com", "h", "TR", 18, True)


def test_email_normalized(store):
    store.create_user("User@Example.COM", "h", "TR", 18, True)
    assert store.get_user_by_email("user@example.com") is not None


def test_session_roundtrip_and_ttl(store):
    u = store.create_user("a@b.com", "h", "TR", 18, True)
    token = store.create_session(u["id"], ttl_days=30)
    found = store.get_user_by_token(token)
    assert found["id"] == u["id"]
    store.delete_session(u["id"], token)
    assert store.get_user_by_token(token) is None


def test_delete_user_cascades(store):
    u = store.create_user("a@b.com", "h", "TR", 18, True)
    t1 = store.create_session(u["id"])
    t2 = store.create_session(u["id"])
    store.delete_user(u["id"])
    assert store.get_user_by_token(t1) is None
    assert store.get_user_by_token(t2) is None
    assert store.get_user_by_email("a@b.com") is None
