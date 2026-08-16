"""FastAPI app factory. Tests build a fresh app per case with a tmp db."""
import os

from fastapi import FastAPI

from app import db
from app.auth.routes import router as auth_router
from app.auth.store import UserStore
from app.content.routes import router as content_router
from app.settings import settings
from app.sync.routes import router as sync_router

DEFAULT_CONTENT_BUILD = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "..", "content", "build"
)


def create_app(db_path: str | None = None, content_build_dir: str | None = None) -> FastAPI:
    app = FastAPI(title="adhd-cbt-backend")
    app.state.db_path = db_path or settings.db_path
    app.state.db = db.get_conn(app.state.db_path)
    app.state.store = UserStore(app.state.db)
    app.state.store.init_schema()
    app.state.content_build_dir = content_build_dir or DEFAULT_CONTENT_BUILD
    app.include_router(auth_router)
    app.include_router(sync_router)
    app.include_router(content_router)

    @app.get("/api/health")
    def health():
        return {"status": "ok"}

    @app.on_event("shutdown")
    def _close():
        app.state.db.close()

    return app
