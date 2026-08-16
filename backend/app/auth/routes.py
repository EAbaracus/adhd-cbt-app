"""Anonymous auth routes + bearer-protected me/logout/delete."""
from fastapi import APIRouter, Depends, HTTPException

from app.auth import passwords
from app.auth.deps import get_current_user, get_store
from app.auth.store import DuplicateEmailError, UserStore

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register")
def register(body: dict, store: UserStore = Depends(get_store)):
    email = body.get("email")
    pw = body.get("password")
    consent = body.get("privacy_consent") is True
    age_min = body.get("age_min")
    age_country = body.get("age_country")
    if not email or not pw or not consent or age_min is None or age_min < 18 or not age_country:
        raise HTTPException(status_code=422, detail="privacy consent and age gate required")
    try:
        user = store.create_user(email, passwords.hash_password(pw), age_country, age_min, True)
    except DuplicateEmailError:
        raise HTTPException(status_code=409, detail="email already registered") from None
    return store.get_public_user(user)


@router.post("/login")
def login(body: dict, store: UserStore = Depends(get_store)):
    user = store.get_user_by_email(body.get("email", ""))
    if user is None or not passwords.verify_password(body.get("password", ""), user["password_hash"]):
        raise HTTPException(status_code=401, detail="invalid credentials")
    token = store.create_session(user["id"])
    return {"token": token, "user": store.get_public_user(user)}


@router.post("/logout")
def logout(request, store: UserStore = Depends(get_store)):
    auth = request.headers.get("Authorization", "")
    token = auth.removeprefix("Bearer ").strip()
    user = store.get_user_by_token(token)
    if user is None:
        raise HTTPException(status_code=401, detail="not authenticated")
    store.delete_session(user["id"], token)
    return {"ok": True}


@router.get("/me")
def me(user: dict = Depends(get_current_user), store: UserStore = Depends(get_store)):
    return store.get_public_user(user)


@router.delete("/me")
def delete_me(request, store: UserStore = Depends(get_store)):
    auth = request.headers.get("Authorization", "")
    token = auth.removeprefix("Bearer ").strip()
    user = store.get_user_by_token(token)
    if user is None:
        raise HTTPException(status_code=401, detail="not authenticated")
    store.delete_user(user["id"])
    return {"ok": True}
