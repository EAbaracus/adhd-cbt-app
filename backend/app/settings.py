"""Env-driven settings. Never read env vars directly in route code."""
import os

DEFAULT_DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "users.db")


class Settings:
    def __init__(self):
        self.db_path = os.environ.get("USERS_DB_PATH", DEFAULT_DB_PATH)
        self.session_ttl_days = int(os.environ.get("SESSION_TTL_DAYS", "30"))
        cors_env = os.environ.get("CORS_ORIGINS", "")
        self.cors_origins = [o.strip() for o in cors_env.split(",") if o.strip()] if cors_env else []


settings = Settings()
