from fastapi.testclient import TestClient
from app.main import create_app
from app.auth.store import UserStore


def _client(tmp_path):
    app = create_app(db_path=str(tmp_path / "users.db"))
    UserStore(app.state.db).init_schema()
    return TestClient(app)


def test_register_login_me_flow(tmp_path):
    client = _client(tmp_path)
    r = client.post("/api/auth/register", json={
        "email": "a@b.com", "password": "secret123", "age_country": "TR", "age_min": 18,
        "privacy_consent": True,
    })
    assert r.status_code == 200
    assert "password_hash" not in r.json()
    r = client.post("/api/auth/login", json={"email": "a@b.com", "password": "secret123"})
    assert r.status_code == 200
    token = r.json()["token"]
    r = client.get("/api/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 200
    assert r.json()["email"] == "a@b.com"


def test_login_no_enumeration(tmp_path):
    client = _client(tmp_path)
    bad1 = client.post("/api/auth/login", json={"email": "nobody@x.com", "password": "p"})
    client.post("/api/auth/register", json={
        "email": "a@b.com", "password": "secret123", "age_country": "TR", "age_min": 18,
        "privacy_consent": True,
    })
    bad2 = client.post("/api/auth/login", json={"email": "a@b.com", "password": "wrong"})
    assert bad1.status_code == bad2.status_code == 401
    assert bad1.json() == bad2.json()


def test_register_requires_consent(tmp_path):
    client = _client(tmp_path)
    r = client.post("/api/auth/register", json={
        "email": "a@b.com", "password": "secret123", "age_country": "TR", "age_min": 18,
        "privacy_consent": False,
    })
    assert r.status_code == 422


def test_duplicate_email_409(tmp_path):
    client = _client(tmp_path)
    payload = {"email": "a@b.com", "password": "secret123", "age_country": "TR",
               "age_min": 18, "privacy_consent": True}
    assert client.post("/api/auth/register", json=payload).status_code == 200
    assert client.post("/api/auth/register", json=payload).status_code == 409


def test_me_requires_token(tmp_path):
    client = _client(tmp_path)
    assert client.get("/api/auth/me").status_code == 401
    assert client.get("/api/auth/me", headers={"Authorization": "Bearer bogus"}).status_code == 401


def test_logout_invalidates(tmp_path):
    client = _client(tmp_path)
    client.post("/api/auth/register", json={
        "email": "a@b.com", "password": "secret123", "age_country": "TR", "age_min": 18,
        "privacy_consent": True,
    })
    token = client.post("/api/auth/login", json={"email": "a@b.com", "password": "secret123"}).json()["token"]
    h = {"Authorization": f"Bearer {token}"}
    assert client.get("/api/auth/me", headers=h).status_code == 200
    assert client.post("/api/auth/logout", headers=h).status_code == 200
    assert client.get("/api/auth/me", headers=h).status_code == 401


def test_delete_me_erases_and_kills_all_tokens(tmp_path):
    client = _client(tmp_path)
    client.post("/api/auth/register", json={
        "email": "a@b.com", "password": "secret123", "age_country": "TR", "age_min": 18,
        "privacy_consent": True,
    })
    t1 = client.post("/api/auth/login", json={"email": "a@b.com", "password": "secret123"}).json()["token"]
    t2 = client.post("/api/auth/login", json={"email": "a@b.com", "password": "secret123"}).json()["token"]
    h1, h2 = {"Authorization": f"Bearer {t1}"}, {"Authorization": f"Bearer {t2}"}
    assert client.delete("/api/auth/me", headers=h1).status_code == 200
    assert client.get("/api/auth/me", headers=h1).status_code == 401
    assert client.get("/api/auth/me", headers=h2).status_code == 401
    assert client.post("/api/auth/login", json={"email": "a@b.com", "password": "secret123"}).status_code == 401
