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
        data_dict = {k: str(v) for k, v in (data or {}).items()}
        notification = messaging.Notification(title=title, body=body)

        # Firebase limits MulticastMessage to 500 tokens
        batch_size = 500
        for i in range(0, len(tokens), batch_size):
            batch_tokens = tokens[i:i + batch_size]
            msg = messaging.MulticastMessage(
                tokens=batch_tokens,
                notification=notification,
                data=data_dict,
            )
            try:
                response = messaging.send_each_for_multicast(msg)
                sent += response.success_count

                if response.failure_count > 0:
                    for idx, res in enumerate(response.responses):
                        if not res.success and res.exception:
                            code = getattr(res.exception, "code", "")
                            if code in ("messaging/registration-token-not-registered", "messaging/invalid-argument"):
                                self.store.remove_push_token(user_id, batch_tokens[idx])
            except Exception:
                # If the whole batch fails, we log or ignore
                pass

        return sent
