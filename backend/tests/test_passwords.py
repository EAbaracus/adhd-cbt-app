import app.auth.passwords as P
import pytest

def test_roundtrip():
    h = P.hash_password("correct horse")
    assert P.verify_password("correct horse", h)


def test_wrong_password_fails():
    h = P.hash_password("right")
    assert not P.verify_password("wrong", h)


def test_hash_is_self_describing():
    h = P.hash_password("x")
    parts = h.split("$")
    assert parts[0] == "pbkdf2_sha256"
    assert int(parts[1]) == P._ITERATIONS
    assert len(parts[2]) > 0 and len(parts[3]) > 0


@pytest.mark.parametrize("invalid_hash", [
    "invalid", # missing parts
    "pbkdf2_sha256$240000$salt$digest$extra", # too many parts
    "pbkdf2_sha256$not_an_int$salt$digest", # ValueError on int()
    "pbkdf2_sha256$240000$!@#$digest", # TypeError/ValueError on b64decode
])
def test_verify_password_malformed_hash(invalid_hash):
    assert not P.verify_password("any_password", invalid_hash)
