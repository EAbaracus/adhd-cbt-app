"""F2 sync: per-user snapshot backup/restore. Idempotent upserts keyed (user_id, item_key)."""

import datetime as dt
import json

from fastapi import APIRouter, Depends

from app.auth.deps import get_current_user, get_store
from app.auth.store import SYNC_KINDS, UserStore

router = APIRouter(prefix="/api/sync", tags=["sync"])


def _upsert(store: UserStore, user_id: int, kind: str, items: dict) -> int:
    if kind not in SYNC_KINDS or not items:
        return 0
    # Optimization: Use executemany for bulk upserts instead of looping with execute
    # This reduces Python-SQLite transition overhead significantly for large sync payloads
    params = []
    for key, item in items.items():
        payload = item.get("payload", item)
        updated_at = item.get("updated_at", "")
        params.append((user_id, key, json.dumps(payload), updated_at))
    cur = store.conn.executemany(
        f"INSERT INTO sync_{kind} (user_id, item_key, payload, updated_at) VALUES (?, ?, ?, ?) "
        "ON CONFLICT (user_id, item_key) DO UPDATE SET payload = excluded.payload, "
        "updated_at = excluded.updated_at",
        params,
    )
    saved = cur.rowcount
    store.conn.commit()
    return saved


@router.put("/backup")
def backup(
    body: dict,
    user: dict = Depends(get_current_user),
    store: UserStore = Depends(get_store),
):
    saved = _upsert(store, user["id"], body.get("kind", ""), body.get("items", {}))
    return {"saved": saved}


@router.get("/snapshot")
def snapshot(
    user: dict = Depends(get_current_user), store: UserStore = Depends(get_store)
):
    out = {k: {} for k in SYNC_KINDS}
    query = " UNION ALL ".join(
        f"SELECT '{kind}' as kind, item_key, payload, updated_at FROM sync_{kind} WHERE user_id = ?"
        for kind in SYNC_KINDS
    )
    params = (user["id"],) * len(SYNC_KINDS)

    rows = store.conn.execute(query, params).fetchall()
    for r in rows:
        out[r["kind"]][r["item_key"]] = {
            "payload": json.loads(r["payload"]),
            "updated_at": r["updated_at"],
        }

    return {"snapshot_at": dt.datetime.now(dt.timezone.utc).isoformat(), **out}
