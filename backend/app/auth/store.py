"""UserStore over a dedicated users.db (account + sync data only)."""
import datetime as dt
import hashlib
import secrets
import sqlite3

SYNC_KINDS = ("progress", "forms", "logs", "settings")

_SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    age_country TEXT NOT NULL,
    age_min INTEGER NOT NULL,
    privacy_consent INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS sessions (
    token_hash TEXT PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS email_verifications (
    token_hash TEXT PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TEXT NOT NULL
);
"""


class DuplicateEmailError(Exception):
    pass


class UserStore:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def init_schema(self):
        self.conn.executescript(_SCHEMA)
        for kind in SYNC_KINDS:
            self.conn.execute(
                f"CREATE TABLE IF NOT EXISTS sync_{kind} ("
                "user_id INTEGER NOT NULL, item_key TEXT NOT NULL, "
                "payload TEXT NOT NULL, updated_at TEXT NOT NULL, "
                "PRIMARY KEY (user_id, item_key))"
            )
        self.conn.commit()

    # ---- users ----
    def create_user(self, email, pw_hash, age_country, age_min, privacy_consent):
        try:
            self.conn.execute(
                "INSERT INTO users (email, password_hash, age_country, age_min, privacy_consent, created_at) "
                "VALUES (?, ?, ?, ?, ?, ?)",
                (email.strip().lower(), pw_hash, age_country, age_min, 1 if privacy_consent else 0,
                 dt.datetime.now(dt.timezone.utc).isoformat()),
            )
            self.conn.commit()
            return self.get_user_by_email(email)
        except sqlite3.IntegrityError as e:
            if "users.email" in str(e):
                raise DuplicateEmailError() from e
            raise

    def get_user_by_email(self, email):
        row = self.conn.execute("SELECT * FROM users WHERE email = ?", (email.strip().lower(),)).fetchone()
        return dict(row) if row else None

    def get_public_user(self, user):
        return {k: v for k, v in user.items() if k != "password_hash"}

    # ---- sessions ----
    def create_session(self, user_id, ttl_days=30):
        token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        expires = (dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=ttl_days)).isoformat()
        self.conn.execute("INSERT INTO sessions (token_hash, user_id, expires_at) VALUES (?, ?, ?)",
                          (token_hash, user_id, expires))
        self.conn.commit()
        return token

    def get_user_by_token(self, token):
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        row = self.conn.execute(
            "SELECT u.* FROM sessions s JOIN users u ON u.id = s.user_id "
            "WHERE s.token_hash = ? AND s.expires_at > ?",
            (token_hash, dt.datetime.now(dt.timezone.utc).isoformat()),
        ).fetchone()
        return dict(row) if row else None

    def delete_session(self, user_id, token):
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        self.conn.execute("DELETE FROM sessions WHERE token_hash = ? AND user_id = ?", (token_hash, user_id))
        self.conn.commit()

    # ---- erasure ----
    def delete_user(self, user_id):
        for kind in SYNC_KINDS:
            self.conn.execute(f"DELETE FROM sync_{kind} WHERE user_id = ?", (user_id,))
        self.conn.execute("DELETE FROM email_verifications WHERE user_id = ?", (user_id,))
        self.conn.execute("DELETE FROM sessions WHERE user_id = ?", (user_id,))
        self.conn.execute("DELETE FROM users WHERE id = ?", (user_id,))
        self.conn.commit()
