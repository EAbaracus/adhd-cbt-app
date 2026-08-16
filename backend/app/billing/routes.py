"""H2 billing: receipt validation + entitlement (3-day grace)."""
import datetime as dt

from fastapi import APIRouter, Depends, HTTPException, Request

from app.auth.deps import get_current_user, get_store

router = APIRouter(prefix="/api/billing", tags=["billing"])

GRACE_DAYS = 3


def _verifier(request: Request, platform: str):
    key = f"{platform}_verifier"
    v = getattr(request.app.state, key, None)
    if v is None:
        v = __import__("app.billing.verifiers", fromlist=["VERIFIERS"]).VERIFIERS[platform]()
        setattr(request.app.state, key, v)
    return v


def _status(user, now=None):
    now = now or dt.datetime.now(dt.timezone.utc)
    expiry_raw = user.get("entitlement_expires_at")
    if not expiry_raw:
        return {"active": False, "expires_at": None}
    expiry = dt.datetime.fromisoformat(expiry_raw)
    active = expiry + dt.timedelta(days=GRACE_DAYS) > now
    return {"active": active, "expires_at": expiry_raw}


@router.post("/receipt")
def receipt(body: dict, request: Request, user: dict = Depends(get_current_user),
            store=Depends(get_store)):
    platform = body.get("platform")
    if platform not in ("apple", "google"):
        raise HTTPException(status_code=400, detail="unsupported platform")
    verifier = _verifier(request, platform)
    try:
        result = verifier.verify(body.get("receipt", ""))
    except ValueError:
        raise HTTPException(status_code=400, detail="invalid receipt") from None
    expires = result.get("expires_at")
    store.set_entitlement(user["id"], expires)
    user["entitlement_expires_at"] = expires
    return {"entitlement": _status(user)}


@router.get("/entitlement")
def entitlement(user: dict = Depends(get_current_user)):
    return _status(user)
