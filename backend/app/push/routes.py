"""Push token registration endpoints. Auth-only (token is user-identifying, A3)."""

from fastapi import APIRouter, Depends, HTTPException

from app.auth.deps import get_current_user, get_store
from app.auth.store import UserStore

router = APIRouter(prefix="/api/push", tags=["push"])


@router.post("/token")
def register_token(
    body: dict,
    user: dict = Depends(get_current_user),
    store: UserStore = Depends(get_store),
):
    token = (body.get("token") or "").strip()
    platform = (body.get("platform") or "").strip().lower()
    if not token:
        raise HTTPException(status_code=422, detail="token required")
    if not platform:
        raise HTTPException(status_code=422, detail="platform required")
    store.upsert_push_token(user["id"], token, platform)
    return {"registered": 1}


@router.delete("/token/{token}")
def remove_token(
    token: str,
    user: dict = Depends(get_current_user),
    store: UserStore = Depends(get_store),
):
    removed = store.remove_push_token(user["id"], token)
    return {"removed": removed}
