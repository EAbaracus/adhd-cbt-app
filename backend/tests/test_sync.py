from fastapi.testclient import TestClient
from app.main import create_app
from app.auth.store import UserStore


def _authed_client(tmp_path, email="a@b.com"):
    app = create_app(db_path=str(tmp_path / "users.db"))
    UserStore(app.state.db).init_schema()
    client = TestClient(app)
    client.post("/api/auth/register", json={
        "email": email, "password": "secret123", "age_country": "TR",
        "age_min": 18, "privacy_consent": True,
    })
    token = client.post("/api/auth/login", json={"email": email, "password": "secret123"}).json()["token"]
    return client, {"Authorization": f"Bearer {token}"}


def test_backup_requires_auth(tmp_path):
    client, _ = _authed_client(tmp_path)
    assert client.put("/api/sync/backup", json={"kind": "forms", "items": {}}).status_code == 401


def test_backup_upsert_idempotent(tmp_path):
    client, h = _authed_client(tmp_path)
    body = {"kind": "forms", "items": {"f1": {"payload": {"v": 1}, "updated_at": "2026-08-15T10:00:00+00:00"}}}
    r1 = client.put("/api/sync/backup", json=body, headers=h)
    assert r1.status_code == 200 and r1.json()["saved"] == 1
    r2 = client.put("/api/sync/backup", json=body, headers=h)
    assert r2.status_code == 200 and r2.json()["saved"] == 1
    r3 = client.put("/api/sync/backup", json={"kind": "forms", "items": {}}, headers=h)
    assert r3.status_code == 200 and r3.json()["saved"] == 0


def test_backup_updates_existing_key(tmp_path):
    client, h = _authed_client(tmp_path)
    client.put("/api/sync/backup", json={"kind": "forms", "items": {"f1": {"payload": {"v": 1}, "updated_at": "t1"}}}, headers=h)
    r = client.put("/api/sync/backup", json={"kind": "forms", "items": {"f1": {"payload": {"v": 2}, "updated_at": "t2"}}}, headers=h)
    assert r.json()["saved"] == 1

