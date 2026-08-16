import app.auth.passwords as P


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
    assert int(parts[1]) == 240_000
    assert len(parts[2]) > 0 and len(parts[3]) > 0
