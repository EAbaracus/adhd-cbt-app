import hashlib, json, pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.build as B


def test_build_produces_manifest_with_hashes(tmp_path, monkeypatch):
    monkeypatch.setattr(B, "CONTENT_DIR", tmp_path)
    monkeypatch.setattr(B, "OUT", tmp_path / "build")
    monkeypatch.setattr(B, "VERSION", "0.1.0")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    (tmp_path / "forms" / "a.json").write_text('{"x": 1}', encoding="utf-8")
    m = B.build()
    assert m["content_version"] == "0.1.0"
    entry = [f for f in m["files"] if f["path"] == "forms/a.json"][0]
    assert entry["sha256"] == hashlib.sha256(b'{"x": 1}').hexdigest()
    assert (tmp_path / "build" / "manifest.json").exists()


def test_build_is_deterministic(tmp_path, monkeypatch):
    monkeypatch.setattr(B, "CONTENT_DIR", tmp_path)
    monkeypatch.setattr(B, "OUT", tmp_path / "build")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    (tmp_path / "forms" / "a.json").write_text('{"x": 1}', encoding="utf-8")
    m1 = B.build()
    m2 = B.build()
    assert m1["files"] == m2["files"]
