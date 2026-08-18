"""Env-driven settings. Never read env vars directly in route code."""

import os

DEFAULT_DB_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "users.db"
)


class Settings:
    def __init__(self):
        self.db_path = os.environ.get("USERS_DB_PATH", DEFAULT_DB_PATH)
        self.session_ttl_days = int(os.environ.get("SESSION_TTL_DAYS", "30"))


settings = Settings()
