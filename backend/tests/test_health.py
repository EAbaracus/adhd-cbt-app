from fastapi.testclient import TestClient
from app.main import create_app


def test_health_ok(tmp_path):
    app = create_app(db_path=str(tmp_path / "users.db"))
    with TestClient(app) as client:
        r = client.get("/api/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
