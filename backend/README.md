# Backend (FastAPI)

M1: email+password auth, F2 sync (idempotent backup/restore), H2 billing
receipt validation + entitlement, versioned content serving.

## Run

```bash
cd backend
uv venv .venv
uv pip install --python .venv/Scripts/python.exe -r requirements.txt pytest httpx
env -u PYTHONPATH .venv/Scripts/python.exe -m pytest tests/ -q
env -u PYTHONPATH .venv/Scripts/python.exe -m uvicorn app.main:create_app --factory --port 8000
```

Always prefix with `env -u PYTHONPATH` — the host `PYTHONPATH` shadows
packages and breaks imports (documented quirk).

## Endpoints (M1 contract)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | /api/health | - | liveness |
| POST | /api/auth/register | - | create account (consent + age gate) |
| POST | /api/auth/login | - | bearer token |
| POST | /api/auth/logout | bearer | revoke token |
| GET | /api/auth/me | bearer | profile |
| DELETE | /api/auth/me | bearer | full erasure (KVKK) |
| PUT | /api/sync/backup | bearer | idempotent per-user upsert |
| GET | /api/sync/snapshot | bearer | full per-user state (restore contract) |
| GET | /api/content/manifest | bearer+entitlement | bundle manifest |
| GET | /api/content/file/{path} | bearer+entitlement | bundle file (traversal-safe) |
| POST | /api/billing/receipt | bearer | validate receipt, set entitlement |
| GET | /api/billing/entitlement | bearer | entitlement status (3-day grace) |

Env: `USERS_DB_PATH` (default `backend/data/users.db`, auto-created),
`CONTENT_BUILD_DIR` (default `../content/build`), `SESSION_TTL_DAYS` (default 30).

## Design notes

- **Auth model:** PBKDF2-HMAC-SHA256 (stdlib) + opaque bearer tokens (sha256
  at rest) — NO JWT/bcrypt/passlib. The spec §3 diagram's "bcrypt, JWT"
  parenthetical is superseded by locked decision #9 (reuse the
  `user-accounts-auth-sync` skill pattern); the API contract is unchanged.
- **Sync:** F2 single-active-device snapshot backup; restore = client-side
  atomic replace (M2); server GET is naturally idempotent. No LWW.
- **Billing:** Apple/Google real verification is stubbed
  (`NotImplementedError`) until store accounts exist (spec open item 2);
  tests inject fake verifiers via `app.state.<platform>_verifier`.
- **Entitlement:** stored on `users.entitlement_expires_at`; 3-day grace
  window. NOTE: an existing dev `users.db` created before M1-7 lacks the
  column — drop/recreate the dev db (tests always use fresh dbs).
