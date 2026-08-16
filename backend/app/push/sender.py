"""Push sender contract. FCM via firebase-admin; Noop when credentials absent.

Anti-engagement guard (I1): this is the ONLY way to emit remote messages, and no
engagement copy is emitted. Remote messages carry user-value events only.
"""
import os
import pathlib

from app.auth.store import UserStore


_CRED_FALLBACK = pathlib.Path(__file__).resolve().parents[2] / "service-account.json"


class PushSender:
    """send(user_id, title, body, data) -> number of devices notified."""

    def send(self, user_id: int, title: str, body: str, data: dict | None = None) -> int:
        raise NotImplementedError


class NoopPushSender(PushSender):
    """No credential configured -> do nothing (local-first: app is fully functional)."""

    def send(self, user_id: int, title: str, body: str, data: dict | None = None) -> int:
        return 0


def _fcm_sender(store: UserStore):
    """Lazily build an FCM-backed sender; returns Noop if firebase-admin/creds absent."""
    try:
        from firebase_admin import credentials, initialize_app, messaging
    except ImportError:
        return NoopPushSender()

    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "")
    if not cred_path and _CRED_FALLBACK.exists():
        cred_path = str(_CRED_FALLBACK)
    if not cred_path or not os.path.exists(cred_path):
        return NoopPushSender()

    from app.push.sender_impl import FcmPushSender

    return FcmPushSender(store, credentials, initialize_app, messaging, cred_path)


def get_sender(store: UserStore) -> PushSender:
    return _fcm_sender(store)
