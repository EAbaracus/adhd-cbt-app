# Firebase Cloud Messaging (FCM) Push Integration — Design

> **Status:** APPROVED (user review, 2026-08-16)
> **Decision:** FCM is free (no monetary cost). The driver for "free alternative" was a
> misperception that FCM cost money; resolved by research → standard FCM is the chosen path.
> The user supplies the Firebase config files (the single external credential blocker).
> **Guiding invariants:** anti-engagement (I1), local-first (graceful no-op without config),
> privacy (A3: push token is user-identifying → auth-only, never third parties).

## 1. Architecture

```
[Flutter app]  ── fcm device token ──▶  [FastAPI backend]
  firebase_core                            push_tokens table (user_id, token, platform)
  firebase_messaging                       POST   /api/push/token        (register/upsert)
  getToken() / onTokenRefresh              DELETE /api/push/token/{token} (logout/uninstall)
        ▲                                          │
        └── local notifications                     ▼
             (timer, local-first)           FcmPushSender (firebase-admin)
                                           ──▶ FCM ──▶ APNs / device
```

- **Client** (app): `firebase_core` + `firebase_messaging`; `PushRegistration` service —
  on login/launch, fetch token and POST to backend; on logout/account delete, DELETE.
  Token refresh (`onTokenRefresh`) re-registers. **Without `google-services.json` the whole
  FCM path is a no-op** (local-first: the app is fully functional without any Firebase config).
- **Backend**: `app/push/` module. `push_tokens` table PK `(user_id, token)`; auth-only
  register/delete endpoints; `FcmPushSender` (firebase-admin, reads service-account env;
  `NoopPushSender` when absent) + invalid-token removal on send failure.
- **Privacy (A3):** push tokens are user-identifying. Endpoints require auth; responses and
  token storage are private; never sent to any third party.

## 2. Message policy (anti-engagement guard)

Remote push carries **only non-engagement, user-value events**:

- entitlement expiry approaching (once, warm)
- account/sync status (transactional, actionable)

**Strictly forbidden** (I1/A4): streaks, "come back" nudges, engagement campaigns, reward
notifications. Timer completion stays **local** (existing `LocalNotificationService`) and is
NOT routed through FCM. The push sender API is the only way to emit remote messages, and no
call site for engagement copy exists in scope.

## 3. External credentials (user-supplied — the only blocker)

| File | Place | Owner-supplied from |
|---|---|---|
| `google-services.json` | `app/android/app/` | Firebase project |
| `GoogleService-Info.plist` | `app/ios/Runner/` | Firebase project |
| service-account JSON | backend env `GOOGLE_APPLICATION_CREDENTIALS` | Firebase project (server) |

Code compiles and tests pass without these; runtime degrades to no-op until present.
`.gitignore` must exclude `google-services.json` + `GoogleService-Info.plist` + service account
JSON (never commit secrets).

> **Note on prior draft:** backend `tests/test_push.py` (token auth, idempotent upsert,
> per-user isolation, delete) was drafted before this design was approved; it is the
> verification spec for the backend component and is carried forward.

## 4. Components & seams

### Backend
- `app/push/routes.py` — `POST /api/push/token {token, platform}` (upsert, returns
  `{"registered": 1}`), `DELETE /api/push/token/{token}` (returns `{"removed": 1}`);
  both via `get_current_user` + `get_store`.
- `app/auth/store.py` — add `push_tokens` table to `init_schema()` +
  `upsert_push_token(user_id, token, platform)`, `remove_push_token(user_id, token)`,
  `get_push_tokens(user_id)`.
- `app/push/sender.py` — `class PushSender` (abstract: `send(user_id, title, body, data)`),
  `class NoopPushSender`, `class FcmPushSender` (firebase-admin; absent credential → noop;
  FCM `UNREGISTERED`/`INVALID_ARGUMENT` → remove token).
- `app/main.py` — register `push_router`.

### App
- `lib/notifications/push_registration.dart` — `PushRegistration(api, sessionManager)`:
  `register()` (get token, POST), `unregister()` (DELETE); guards on `PushTokenProvider`.
- `lib/notifications/push_token_provider.dart` — `abstract PushTokenProvider { Future<String?> token; Stream<String?> refreshes; }`; `NoopPushTokenProvider` (no config) is the default.

## 5. Testing gate

- **Backend:** `tests/test_push.py` — register requires auth; upsert idempotent; per-user
  isolation (A's token survives B's delete); delete removes row. `PushSender` tested with fake:
  Noop is no-op; FcmPushSender no-credential → noop; invalid-token → row removed.
- **App:** `PushRegistration` with fake token provider: register posts token; unregister
  deletes; no-op provider does nothing; token refresh re-registers.
- Existing suites stay green: **124 app + 29 backend tests** + `analyze` clean.
- `flutter test` does not touch the Android build; native build requires the user's config
  (documented, not a test blocker).

## 6. Scope lock

- No new features beyond push plumbing. No engagement messaging. Timer stays local.
- No production DB writes by this work (backend schema change is a normal migration in the
  dev DB; the action here is adding a table + endpoints, code-only).
- External credentials are the only remaining manual step; everything else ships now.

## 7. Commit discipline

- Design doc: `docs(ui)`-style isolated commit (this file).
- Implementation: separate logical commits — backend push module + tests, app push
  registration + tests, `.gitignore` for secrets — each reviewer-gated / verified before merge.
- Never commit the config files or service-account JSON.
