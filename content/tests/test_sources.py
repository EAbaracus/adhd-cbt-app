"""Registry invariants for content/sources/ (Phase 1)."""
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.validate as V


def test_sources_catalog_complete():
    sources = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SOURCES_DIR)}
    expected = {
        "ramsay-rostain-2015", "barkley-2015", "safren-2010-cbt-rct",
        "knouse-safren-2010", "sprich-2016-adolescent", "solanto-2008-mct",
        "mitchell-2013-mindfulness", "antshel-barkley-2015",
        "kendall-braswell-1993", "dupaul-stoner-2016",
    }
    assert expected <= set(sources), f"missing: {expected - set(sources)}"
    assert len(sources) == 10, f"expected 10, got {len(sources)}"


def test_sources_pass_validation():
    errors = V.validate()
    source_errors = [e for e in errors if e.startswith("source")]
    assert source_errors == [], f"source validation errors: {source_errors}"


def test_id_mismatch_detection(tmp_path, monkeypatch):
    """When id != filename stem, validate() must flag it."""
    # Point all dirs to isolated tmp so validate() sees only our fixture.
    monkeypatch.setattr(V, "SCHEMA_DIR", tmp_path / "schema")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    # Copy schemas so validate() can load them.
    import shutil
    shutil.copy(
        V.CONTENT_DIR / "schema" / "source.schema.json",
        tmp_path / "schema" / "source.schema.json",
    )
    shutil.copy(
        V.CONTENT_DIR / "schema" / "session.schema.json",
        tmp_path / "schema" / "session.schema.json",
    )
    shutil.copy(
        V.CONTENT_DIR / "schema" / "form.schema.json",
        tmp_path / "schema" / "form.schema.json",
    )
    bad = {
        "id": "mismatched-id", "author": "A", "year": 2010, "title": "T",
        "publication": "P", "source_type": "rct", "access_status": "blocked_404",
        "evidence_role": "efficacy_evidence", "doi": "10.1000/a.b",
    }
    (tmp_path / "sources" / "good-name.json").write_text(json.dumps(bad), encoding="utf-8")
    errors = V.validate()
    assert any("id must match filename stem" in e for e in errors), errors


def test_journal_type_requires_doi_or_pmid(tmp_path, monkeypatch):
    """rct without doi or pmid must error."""
    monkeypatch.setattr(V, "SCHEMA_DIR", tmp_path / "schema")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    import shutil
    for name in ("source.schema.json", "session.schema.json", "form.schema.json"):
        shutil.copy(V.CONTENT_DIR / "schema" / name, tmp_path / "schema" / name)
    no_id = {
        "id": "j-2010", "author": "A", "year": 2010, "title": "T",
        "publication": "P", "source_type": "rct", "access_status": "blocked_404",
        "evidence_role": "efficacy_evidence",
    }
    (tmp_path / "sources" / "j-2010.json").write_text(json.dumps(no_id), encoding="utf-8")
    errors = V.validate()
    assert any("journal-type needs doi or pmid" in e for e in errors), errors
    # both present → OK
    both = dict(no_id, doi="10.1000/a.b", pmid="12345678")
    (tmp_path / "sources" / "j-2010.json").write_text(json.dumps(both), encoding="utf-8")
    errors = V.validate()
    assert not any("journal-type" in e for e in errors), errors


def test_bad_doi_format_rejected(tmp_path, monkeypatch):
    import shutil
    monkeypatch.setattr(V, "SCHEMA_DIR", tmp_path / "schema")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    for name in ("source.schema.json", "session.schema.json", "form.schema.json"):
        shutil.copy(V.CONTENT_DIR / "schema" / name, tmp_path / "schema" / name)
    bad = {
        "id": "j-2010", "author": "A", "year": 2010, "title": "T",
        "publication": "P", "source_type": "rct", "access_status": "blocked_404",
        "evidence_role": "efficacy_evidence", "doi": "not-a-doi", "pmid": "12345678",
    }
    (tmp_path / "sources" / "j-2010.json").write_text(json.dumps(bad), encoding="utf-8")
    errors = V.validate()
    assert any("invalid doi" in e for e in errors), errors


def test_book_type_requires_valid_isbn(tmp_path, monkeypatch):
    import shutil
    monkeypatch.setattr(V, "SCHEMA_DIR", tmp_path / "schema")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "schema").mkdir()
    (tmp_path / "forms").mkdir()
    (tmp_path / "sessions").mkdir()
    (tmp_path / "sources").mkdir()
    for name in ("source.schema.json", "session.schema.json", "form.schema.json"):
        shutil.copy(V.CONTENT_DIR / "schema" / name, tmp_path / "schema" / name)
    no_isbn = {
        "id": "b-1993", "author": "A", "year": 1993, "title": "T",
        "publication": "P", "source_type": "handbook",
        "access_status": "blocked_404", "evidence_role": "mechanism",
    }
    (tmp_path / "sources" / "b-1993.json").write_text(json.dumps(no_isbn), encoding="utf-8")
    errors = V.validate()
    assert any("book-type needs isbn" in e for e in errors), errors
    bad_isbn = dict(no_isbn, isbn="123")
    (tmp_path / "sources" / "b-1993.json").write_text(json.dumps(bad_isbn), encoding="utf-8")
    errors = V.validate()
    assert any("invalid isbn" in e for e in errors), errors
    # ISBN-10 (no 978/979 prefix) must also validate — spec regex supports optional prefix.
    isbn10 = dict(no_isbn, isbn="0898620135")
    (tmp_path / "sources" / "b-1993.json").write_text(json.dumps(isbn10), encoding="utf-8")
    errors = V.validate()
    assert not any("isbn" in e for e in errors), errors


def test_no_duplicate_source_ids():
    sources = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SOURCES_DIR)}
    ids = [s["id"] for s in sources.values()]
    assert len(ids) == len(set(ids)), f"duplicate source ids: {ids}"


def test_journals_have_identifiers():
    sources = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SOURCES_DIR)}
    for sid, s in sources.items():
        if s["source_type"] in V.SOURCE_JOURNAL_TYPES:
            assert s.get("doi") or s.get("pmid"), f"{sid}: journal-type with no identifier"


def test_books_have_isbn():
    sources = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SOURCES_DIR)}
    for sid, s in sources.items():
        if s["source_type"] in V.SOURCE_BOOK_TYPES:
            assert s.get("isbn"), f"{sid}: book-type with no isbn"
