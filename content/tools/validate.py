"""Validate content/ against JSON Schemas + custom invariants. Exit 0 = OK."""
import json
import pathlib
import re
import sys

import jsonschema

CONTENT_DIR = pathlib.Path(__file__).resolve().parent.parent
SCHEMA_DIR = CONTENT_DIR / "schema"
SESSIONS_DIR = CONTENT_DIR / "sessions"
FORMS_DIR = CONTENT_DIR / "forms"
SOURCES_DIR = CONTENT_DIR / "sources"

ISO_DATE_RE = re.compile(r"\b20\d{2}-\d{2}-\d{2}\b")

DOI_RE = re.compile(r"^10\.\d{4,9}/\S+$")
PMID_RE = re.compile(r"^\d{5,9}$")
ISBN_RE = re.compile(r"^(97[89])?\d{9}[\dX]$")

SOURCE_BOOK_TYPES = {
    "clinical_manual", "handbook", "patient_workbook", "school_intervention_guide"}
SOURCE_JOURNAL_TYPES = {
    "rct", "literature_review", "meta_analysis", "pilot_study"}


def _load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def _glob_json(directory):
    return sorted(directory.glob("*.json"))


def validate():
    """Return list of error strings; empty list means content is valid."""
    errors = []
    session_schema = _load_json(SCHEMA_DIR / "session.schema.json")
    form_schema = _load_json(SCHEMA_DIR / "form.schema.json")
    sources_schema = _load_json(SCHEMA_DIR / "source.schema.json")
    forms = {p.stem: _load_json(p) for p in _glob_json(FORMS_DIR)}
    sessions = {p.stem: _load_json(p) for p in _glob_json(SESSIONS_DIR)}
    sources = {p.stem: _load_json(p) for p in _glob_json(SOURCES_DIR)}

    for fid, form in forms.items():
        try:
            jsonschema.validate(form, form_schema)
        except jsonschema.ValidationError as e:
            errors.append(f"form {fid}: schema: {e.message}")

    for sid, source in sources.items():
        try:
            jsonschema.validate(source, sources_schema)
        except jsonschema.ValidationError as e:
            errors.append(f"source {sid}: schema: {e.message}")
        if source.get("id") != sid:
            errors.append(
                f"source {sid}: id must match filename stem ({source.get('id')!r})")
        st = source.get("source_type")
        if st in SOURCE_JOURNAL_TYPES:
            has_doi = bool(source.get("doi"))
            has_pmid = bool(source.get("pmid"))
            if not (has_doi or has_pmid):
                errors.append(f"source {sid}: journal-type needs doi or pmid")
            if has_doi and not DOI_RE.match(source["doi"]):
                errors.append(f"source {sid}: invalid doi {source['doi']!r}")
            if has_pmid and not PMID_RE.match(source["pmid"]):
                errors.append(f"source {sid}: invalid pmid {source['pmid']!r}")
        elif st in SOURCE_BOOK_TYPES:
            isbn = source.get("isbn")
            if not isbn:
                errors.append(f"source {sid}: book-type needs isbn")
            elif not ISBN_RE.match(isbn):
                errors.append(f"source {sid}: invalid isbn {isbn!r}")

    source_ids = set(sources.keys())
    for sid, session in sessions.items():
        cp_ids = [c["id"] for c in session["checkpoints"]]
        seen_cp = set()
        for c in session["checkpoints"]:
            if c["id"] in seen_cp:
                errors.append(f"session {sid}: duplicate checkpoint id {c['id']!r}")
            seen_cp.add(c["id"])
            if "evidence" in c:
                if not c["id"].startswith("read-evidence-"):
                    errors.append(
                        f"session {sid}: checkpoint {c['id']!r} has evidence but "
                        f"is not a read-evidence-* checkpoint (convention: "
                        f"evidence only on read-evidence-* checkpoints)")
                for ev in c["evidence"]:
                    src = ev.get("source")
                    if src not in source_ids:
                        errors.append(
                            f"session {sid}: checkpoint {c['id']!r} evidence "
                            f"source {src!r} not found in sources catalog")
        try:
            jsonschema.validate(session, session_schema)
        except jsonschema.ValidationError as e:
            errors.append(f"session {sid}: schema: {e.message}")
        cp_ids = [c["id"] for c in session["checkpoints"]]
        if len(cp_ids) != len(set(cp_ids)):
            errors.append(f"session {sid}: duplicate checkpoint ids")
        for cp in session["checkpoints"]:
            ref = cp.get("formRef")
            if ref is not None and ref.removeprefix("form:") not in forms:
                errors.append(f"session {sid} {cp['id']}: unknown formRef {ref}")
            for req in cp.get("requires", []):
                if req not in cp_ids:
                    errors.append(f"session {sid} {cp['id']}: requires unknown {req}")
            for text in cp["content"]["en"]:
                if ISO_DATE_RE.search(text):
                    errors.append(f"session {sid} {cp['id']}: ISO date violates G2: {text!r}")

    seen_ids = {s["id"] for s in sessions.values()} | {f["id"] for f in forms.values()}
    if len(seen_ids) != len(sessions) + len(forms):
        dupes = [i for i, c in {**{k: v["id"] for k, v in sessions.items()},
                                **{k: v["id"] for k, v in forms.items()}}.items()]
        errors.append(f"duplicate ids across catalog: {dupes}")
    return errors


def main():
    errors = validate()
    if errors:
        for e in errors:
            print(f"ERROR: {e}")
        sys.exit(1)
    n_s = len(list(_glob_json(SESSIONS_DIR)))
    n_f = len(list(_glob_json(FORMS_DIR)))
    n_src = len(list(_glob_json(SOURCES_DIR)))
    print(f"OK: {n_s} sessions, {n_f} forms, {n_src} sources")


if __name__ == "__main__":
    main()
