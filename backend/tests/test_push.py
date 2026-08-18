from fastapi.testclient import TestClient
from app.main import create_app
from app.auth.store import UserStore


def _authed_client(tmp_path, email="a@b.com"):
    app = create_app(db_path=str(tmp_path / "users.db"))
    UserStore(app.state.db).init_schema()
    client = TestClient(app)
    client.post(
        "/api/auth/register",
        json={
            "email": email,
            "password": "secret123",
            "age_country": "TR",
            "age_min": 18,
            "privacy_consent": True,
        },
    )
    token = client.post(
        "/api/auth/login", json={"email": email, "password": "secret123"}
    ).json()["token"]
    return client, {"Authorization": f"Bearer {token}"}


def test_token_requires_auth(tmp_path):
    client, _ = _authed_client(tmp_path)
    assert (
        client.post(
            "/api/push/token", json={"token": "t1", "platform": "android"}
        ).status_code
        == 401
    )


def test_registers_token(tmp_path):
    client, h = _authed_client(tmp_path)
    r = client.post(
        "/api/push/token", json={"token": "t1", "platform": "android"}, headers=h
    )
    assert r.status_code == 200 and r.json()["registered"] == 1


def test_registration_idempotent(tmp_path):
    client, h = _authed_client(tmp_path)
    body = {"token": "t1", "platform": "ios"}
    r1 = client.post("/api/push/token", json=body, headers=h)
    r2 = client.post("/api/push/token", json=body, headers=h)
    assert r1.json()["registered"] == 1 and r2.json()["registered"] == 1


def test_per_user_isolation(tmp_path):
    client_a, h_a = _authed_client(tmp_path, "a@b.com")
    client_b, h_b = _authed_client(tmp_path, "b@c.com")


def test_delete_token(tmp_path):
    client, h = _authed_client(tmp_path)
    client.post(
        "/api/push/token", json={"token": "t-rm", "platform": "android"}, headers=h
    )
    r = client.delete("/api/push/token/t-rm", headers=h)
    assert r.status_code == 200 and r.json()["removed"] == 1
    store = UserStore(client.app.state.db)
    store.init_schema()
    assert (
        store.conn.execute(
            "SELECT COUNT(*) FROM push_tokens WHERE token='t-rm'"
        ).fetchone()[0]
        == 0
    )
