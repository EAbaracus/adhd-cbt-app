"""FastAPI app factory. Tests build a fresh app per case with a tmp db."""
from fastapi import FastAPI

from app import db
from app.settings import settings


def create_app(db_path: str | None = None) -> FastAPI:
    app = FastAPI(title="adhd-cbt-backend")
    app.state.db_path = db_path or settings.db_path
    app.state.db = db.get_conn(app.state.db_path)

    @app.get("/api/health")
    def health():
        return {"status": "ok"}

    @app.on_event("shutdown")
    def _close():
        app.state.db.close()

    return app
