import os

import pytest

from app.push.sender import NoopPushSender, get_sender, _CRED_FALLBACK


def test_noop_when_no_credentials(monkeypatch, tmp_path):
    # point fallback + env at a path that does not exist
    monkeypatch.delenv("GOOGLE_APPLICATION_CREDENTIALS", raising=False)
    monkeypatch.setattr("app.push.sender._CRED_FALLBACK", tmp_path / "none.json")
    assert isinstance(get_sender(None), NoopPushSender)


def test_fcm_selected_when_credentials_exist(monkeypatch):
    from app.push.sender_impl import FcmPushSender

    monkeypatch.delenv("GOOGLE_APPLICATION_CREDENTIALS", raising=False)
    # the real backend/service-account.json is present in the repo
    monkeypatch.setattr("app.push.sender._CRED_FALLBACK", _CRED_FALLBACK)
    sender = get_sender(None)
    assert isinstance(sender, FcmPushSender)


def test_env_override_wins(monkeypatch, tmp_path):
    # nonexistent env value -> Noop even if fallback file exists
    monkeypatch.setenv("GOOGLE_APPLICATION_CREDENTIALS", str(tmp_path / "nope.json"))
    monkeypatch.setattr("app.push.sender._CRED_FALLBACK", _CRED_FALLBACK)
    assert isinstance(get_sender(None), NoopPushSender)
