"""Firebase-admin backed sender (only constructed when credentials exist).

Kept import-light (firebase_admin imported in the factory) so the backend runs
and tests green without the heavy SDK. Noop when creds absent is in sender.py.
"""


class FcmPushSender:
    def __init__(self, store, credentials, initialize_app, messaging, cred_path):
        self.store = store
        self._messaging = messaging
        try:
            cred = credentials.Certificate(cred_path)
            initialize_app(credential=cred)
        except Exception:
            self._app = None
        else:
            self._app = None  # default app

    def _resolve_messaging(self):
        try:
            from firebase_admin import messaging

            return messaging
        except Exception:
            return self._messaging

    def send(self, user_id, title, body, data=None):
        if self._app is None:
            return 0
        messaging = self._resolve_messaging()
        tokens = [t["token"] for t in self.store.get_push_tokens(user_id)]
        if not tokens:
            return 0
        sent = 0
        for token in tokens:
            msg = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                data={k: str(v) for k, v in (data or {}).items()},
                token=token,
            )
            try:
                messaging.send(msg)
                sent += 1
            except Exception as e:
                code = getattr(e, "code", "")
                if code in (
                    "messaging/registration-token-not-registered",
                    "messaging/invalid-argument",
                ):
                    self.store.remove_push_token(user_id, token)
        return sent
