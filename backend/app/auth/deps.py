"""Bearer-token dependency. 401 on missing/invalid/expired token."""

from fastapi import Depends, HTTPException, Request

from app.auth.store import UserStore


def get_store(request: Request) -> UserStore:
    return request.app.state.store


def get_current_user(request: Request, store: UserStore = Depends(get_store)):
    auth = request.headers.get("Authorization", "")
    if not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="not authenticated")
    token = auth.removeprefix("Bearer ").strip()
    user = store.get_user_by_token(token)
    if user is None:
        raise HTTPException(status_code=401, detail="not authenticated")
    return user


def require_entitlement(user: dict = Depends(get_current_user)):
    from app.billing.routes import _status

    if not _status(user)["active"]:
        raise HTTPException(status_code=403, detail="entitlement required")
    return user
