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

ISO_DATE_RE = re.compile(r"\b20\d{2}-\d{2}-\d{2}\b")


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
    forms = {p.stem: _load_json(p) for p in _glob_json(FORMS_DIR)}
    sessions = {p.stem: _load_json(p) for p in _glob_json(SESSIONS_DIR)}

    for fid, form in forms.items():
        try:
            jsonschema.validate(form, form_schema)
        except jsonschema.ValidationError as e:
            errors.append(f"form {fid}: schema: {e.message}")

    for sid, session in sessions.items():
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
    print(f"OK: {n_s} sessions, {n_f} forms")


if __name__ == "__main__":
    main()
