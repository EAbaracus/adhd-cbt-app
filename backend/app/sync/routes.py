"""F2 sync: per-user snapshot backup/restore. Idempotent upserts keyed (user_id, item_key)."""
import datetime as dt
import json

from fastapi import APIRouter, Depends

from app.auth.deps import get_current_user, get_store
from app.auth.store import SYNC_KINDS, UserStore

router = APIRouter(prefix="/api/sync", tags=["sync"])


def _upsert(store: UserStore, user_id: int, kind: str, items: dict) -> int:
    if kind not in SYNC_KINDS:
        return 0
    saved = 0
    for key, item in items.items():
        payload = item.get("payload", item)
        updated_at = item.get("updated_at", "")
        cur = store.conn.execute(
            f"INSERT INTO sync_{kind} (user_id, item_key, payload, updated_at) VALUES (?, ?, ?, ?) "
            "ON CONFLICT (user_id, item_key) DO UPDATE SET payload = excluded.payload, "
            "updated_at = excluded.updated_at",
            (user_id, key, json.dumps(payload), updated_at),
        )
        saved += cur.rowcount
    store.conn.commit()
    return saved


@router.put("/backup")
def backup(body: dict, user: dict = Depends(get_current_user), store: UserStore = Depends(get_store)):
    saved = _upsert(store, user["id"], body.get("kind", ""), body.get("items", {}))
    return {"saved": saved}


@router.get("/snapshot")
def snapshot(user: dict = Depends(get_current_user), store: UserStore = Depends(get_store)):
    out = {}
    for kind in SYNC_KINDS:
        rows = store.conn.execute(
            f"SELECT item_key, payload, updated_at FROM sync_{kind} WHERE user_id = ?", (user["id"],)
        ).fetchall()
        out[kind] = {r["item_key"]: {"payload": json.loads(r["payload"]), "updated_at": r["updated_at"]} for r in rows}
    return {"snapshot_at": dt.datetime.now(dt.timezone.utc).isoformat(), **out}
