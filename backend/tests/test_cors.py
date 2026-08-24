from fastapi.testclient import TestClient

def test_cors_headers(tmp_path):
    import app.settings as settings_module
    original_origins = settings_module.settings.cors_origins
    settings_module.settings.cors_origins = ["http://localhost:3000", "http://localhost:8080"]

    from app.main import create_app
    app = create_app(db_path=str(tmp_path / "users.db"))

    try:
        with TestClient(app) as client:
            response = client.options(
                "/api/health",
                headers={
                    "Origin": "http://localhost:3000",
                    "Access-Control-Request-Method": "GET"
                }
            )

        assert response.status_code == 200
        assert response.headers.get("access-control-allow-origin") == "http://localhost:3000"
    finally:
        settings_module.settings.cors_origins = original_origins
