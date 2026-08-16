"""Evidence-layer invariants for content/sessions/ (Phase 2)."""
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.validate as V


def _load_sessions():
    return {p.stem: json.load(open(p, encoding="utf-8"))
            for p in V._glob_json(V.SESSIONS_DIR)}


def _load_sources():
    return {p.stem: json.load(open(p, encoding="utf-8"))
            for p in V._glob_json(V.SOURCES_DIR)}


def test_sources_catalog_complete():
    sources = _load_sources()
    expected = {
        "ramsay-rostain-2015", "barkley-2015", "safren-2010-cbt-rct",
        "knouse-safren-2010", "sprich-2016-adolescent", "solanto-2008-mct",
        "mitchell-2013-mindfulness", "antshel-barkley-2015",
        "kendall-braswell-1993", "dupaul-stoner-2016",
    }
    assert expected <= set(sources)
    assert len(sources) == 10


def test_validate_green():
    errors = V.validate()
    assert errors == [], f"validation errors: {errors}"


def test_evidence_sources_resolve():
    sessions = _load_sessions()
    source_ids = set(_load_sources().keys())
    for sid, s in sessions.items():
        for cp in s["checkpoints"]:
            for ev in cp.get("evidence", []):
                assert ev["source"] in source_ids, f"{sid} {cp['id']}: {ev['source']}"


def test_evidence_only_on_read_evidence_checkpoints():
    sessions = _load_sessions()
    for sid, s in sessions.items():
        for cp in s["checkpoints"]:
            if "evidence" in cp:
                assert cp["id"].startswith("read-evidence-"), f"{sid} {cp['id']}"


def test_evidence_checkpoints_present():
    sessions = _load_sessions()
    expected = {
        "01-psycho-what-is-adhd": {"read-evidence-combined", "read-evidence-biology"},
        "04-org-priorities": {"read-evidence-mct"},
        "08-dist-environment": {"read-evidence-ef"},
        "12-proc-procrastination": {"read-evidence-implementation"},
        "13-relapse-prevention": {"read-evidence-maintenance"},
    }
    for sid, cps in expected.items():
        ids = {c["id"] for c in sessions[sid]["checkpoints"]}
        assert cps <= ids, f"{sid}: missing {cps - ids}"


def test_existing_checkpoint_ids_unchanged():
    """G2/G4 guard: pre-enrichment checkpoint ids are frozen; only
    read-evidence-* additions may exist. (git diff is the real gate; this
    is a regression tripwire against id renames.)"""
    sessions = _load_sessions()
    frozen = {
        "01-psycho-what-is-adhd": {
            "ritual-check", "ritual-meds", "read-adhd", "read-cbt-model",
            "ex-map", "hw-read", "ref-obstacles"},
        "04-org-priorities": {
            "ritual-check", "ritual-meds", "read-abc", "ex-rate",
            "hw-read", "ref-obstacles"},
        "08-dist-environment": {
            "ritual-check", "ritual-meds", "read-env", "ex-changes",
            "hw-read", "ref-obstacles"},
        "12-proc-procrastination": {
            "ritual-check", "ritual-meds", "read-avoid", "ex-proscons",
            "hw-read", "ref-obstacles"},
        "13-relapse-prevention": {
            "ritual-check", "ritual-meds", "read-maintain", "ex-rate",
            "hw-read", "ref-obstacles"},
    }
    for sid, frozen_ids in frozen.items():
        ids = {c["id"] for c in sessions[sid]["checkpoints"]}
        assert frozen_ids <= ids, f"{sid}: missing frozen {frozen_ids - ids}"


def test_unknown_evidence_source_rejected(tmp_path, monkeypatch):
    import shutil
    monkeypatch.setattr(V, "SCHEMA_DIR", tmp_path / "schema")
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    for name in ("source.schema.json", "session.schema.json", "form.schema.json"):
        shutil.copy(V.CONTENT_DIR / "schema" / name, tmp_path / "schema" / name)
    sess = {"id": "s1", "order": 1, "module": "psychoeducation",
            "title": {"en": "t"},
            "checkpoints": [
                {"id": "read-evidence-x", "type": "reading", "title": {"en": "t"},
                 "content": {"en": ["x"]},
                 "evidence": [{"source": "does-not-exist",
                               "claim": {"en": "c", "tr": "c"}}]}]}
    (tmp_path / "sessions" / "01.json").write_text(
        json.dumps(sess), encoding="utf-8")
    errs = V.validate()
    assert any("does-not-exist" in e for e in errs)


def test_evidence_without_read_prefix_rejected(tmp_path, monkeypatch):
    """A non-read-evidence-* checkpoint with evidence must error."""
    import shutil
    monkeypatch.setattr(V, "SCHEMA_DIR", tmp_path / "schema")
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    for name in ("source.schema.json", "session.schema.json", "form.schema.json"):
        shutil.copy(V.CONTENT_DIR / "schema" / name, tmp_path / "schema" / name)
    src = {"id": "s1", "year": 2020, "author": "A", "title": "T",
           "publication": "P", "source_type": "rct", "access_status": "blocked_404",
           "evidence_role": "efficacy_evidence", "doi": "10.1000/a.b"}
    (tmp_path / "sources" / "s1.json").write_text(json.dumps(src), encoding="utf-8")
    sess = {"id": "s2", "order": 1, "module": "psychoeducation",
            "title": {"en": "t"},
            "checkpoints": [
                {"id": "read-mistake", "type": "reading", "title": {"en": "t"},
                 "content": {"en": ["x"]},
                 "evidence": [{"source": "s1",
                               "claim": {"en": "c", "tr": "c"}}]}]}
    (tmp_path / "sessions" / "01.json").write_text(
        json.dumps(sess), encoding="utf-8")
    errs = V.validate()
    assert any("read-evidence-" in e and "not a read-evidence" in e
               or "is not a read-evidence" in e for e in errs), errs
