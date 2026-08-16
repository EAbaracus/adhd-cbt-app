import json
from fastapi.testclient import TestClient
from app.main import create_app
from app.auth.store import UserStore


def _client(tmp_path, build_dir):
    app = create_app(db_path=str(tmp_path / "users.db"), content_build_dir=str(build_dir))
    UserStore(app.state.db).init_schema()
    client = TestClient(app)
    client.post("/api/auth/register", json={
        "email": "a@b.com", "password": "secret123", "age_country": "TR",
        "age_min": 18, "privacy_consent": True,
    })
    login = client.post("/api/auth/login", json={"email": "a@b.com", "password": "secret123"}).json()
    token = login["token"]
    # M1-7: content routes require entitlement — grant one directly for content tests
    app.state.store.set_entitlement(login["user"]["id"], "2099-01-01T00:00:00+00:00")
    return client, {"Authorization": f"Bearer {token}"}


def test_manifest_served(tmp_path):
    build = tmp_path / "build"
    build.mkdir()
    (build / "manifest.json").write_text(json.dumps({"content_version": "0.1.0", "files": []}), encoding="utf-8")
    client, h = _client(tmp_path, build)
    r = client.get("/api/content/manifest", headers=h)
    assert r.status_code == 200
    assert r.json()["content_version"] == "0.1.0"


def test_file_served_and_traversal_blocked(tmp_path):
    build = tmp_path / "build"
    (build / "sessions").mkdir(parents=True)
    (build / "sessions" / "01.json").write_text("{}", encoding="utf-8")
    client, h = _client(tmp_path, build)
    r = client.get("/api/content/file/sessions/01.json", headers=h)
    assert r.status_code == 200 and r.json() == {}
    r = client.get("/api/content/file/../../etc/passwd", headers=h)
    assert r.status_code == 400 or r.status_code == 404


def test_content_requires_auth(tmp_path):
    build = tmp_path / "build"
    build.mkdir()
    (build / "manifest.json").write_text("{}", encoding="utf-8")
    client, _ = _client(tmp_path, build)
    assert client.get("/api/content/manifest").status_code == 401
