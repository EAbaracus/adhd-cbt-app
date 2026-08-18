from fastapi.testclient import TestClient
from app.main import create_app
from app.auth.store import UserStore


class FakeVerifier:
    def __init__(
        self,
        *,
        active=True,
        expires_at="2099-01-01T00:00:00+00:00",
        raise_invalid=False,
    ):
        self.active, self.expires_at, self.raise_invalid = (
            active,
            expires_at,
            raise_invalid,
        )

    def verify(self, receipt: str):
        if self.raise_invalid:
            raise ValueError("bad receipt")
        return {"active": self.active, "expires_at": self.expires_at}


def _client(tmp_path):
    app = create_app(db_path=str(tmp_path / "users.db"))
    app.state.apple_verifier = FakeVerifier()
    app.state.google_verifier = FakeVerifier()
    UserStore(app.state.db).init_schema()
    client = TestClient(app)
    client.post(
        "/api/auth/register",
        json={
            "email": "a@b.com",
            "password": "secret123",
            "age_country": "TR",
            "age_min": 18,
            "privacy_consent": True,
        },
    )
    token = client.post(
        "/api/auth/login", json={"email": "a@b.com", "password": "secret123"}
    ).json()["token"]
    return client, {"Authorization": f"Bearer {token}"}


def test_valid_receipt_grants_entitlement(tmp_path):
    client, h = _client(tmp_path)
    r = client.post(
        "/api/billing/receipt", json={"platform": "apple", "receipt": "abc"}, headers=h
    )
    assert r.status_code == 200
    assert r.json()["entitlement"]["active"] is True
    e = client.get("/api/billing/entitlement", headers=h).json()
    assert e["active"] is True


def test_invalid_receipt_400(tmp_path):
    client, h = _client(tmp_path)
    client.app.state.apple_verifier = FakeVerifier(raise_invalid=True)
    r = client.post(
        "/api/billing/receipt", json={"platform": "apple", "receipt": "bad"}, headers=h
    )
    assert r.status_code == 400


def test_unknown_platform_400(tmp_path):
    client, h = _client(tmp_path)
    r = client.post(
        "/api/billing/receipt", json={"platform": "web", "receipt": "x"}, headers=h
    )
    assert r.status_code == 400


def test_entitlement_gates_content(tmp_path):
    build = tmp_path / "build"
    build.mkdir()
    (build / "manifest.json").write_text("{}", encoding="utf-8")
    client, h = _client(tmp_path)
    client.app.state.content_build_dir = str(build)
    assert client.get("/api/content/manifest", headers=h).status_code == 403
    client.post(
        "/api/billing/receipt", json={"platform": "apple", "receipt": "abc"}, headers=h
    )
    assert client.get("/api/content/manifest", headers=h).status_code == 200
