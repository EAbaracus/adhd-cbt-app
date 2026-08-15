# M0 — Content Pipeline & 12-Week Program Content Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the content pipeline (schemas → validator → versioned bundle) and author the full 12-week EN program content as validated, l10n-ready data.

**Architecture:** Content lives as plain JSON in `content/sessions/` + `content/forms/`, validated against JSON Schemas (`content/schema/`) by a Python validator (`content/tools/validate.py`), and assembled into a versioned, sha256-manifested bundle by `content/tools/build.py`. All user-facing strings are locale-keyed (`{"en": ...}`) — l10n-ready from day 1. Content is immutable once bundled; OTA delivery arrives in M5.

**Tech Stack:** Python 3.11 (system: `C:/Users/eltun/AppData/Local/Programs/Python/Python311/python.exe`), uv venv at `content/.venv`, pytest, jsonschema. See `pytest-windows-venv` skill for the venv/pytest pattern on Windows.

**Spec:** `docs/superpowers/specs/2026-08-15-adhd-cbt-app-design.md`

## Global Constraints

- **G1 Content-is-data**: every session/form is JSON data; no program content in code.
- **G2 Calendar-independent**: `order` is metadata (suggested sequence) only. NO ISO dates (`20\d{2}-\d{2}-\d{2}`) anywhere in content. Progression is engine-side, completion-based.
- **G3 l10n-ready**: every user-facing string is `{"en": "..."}`; `en` required, other locales allowed. Plain English, no markdown, no emoji.
- **G4 Original content ONLY**: OUP workbook is a conceptual reference. No verbatim copying, no APA/DSM verbatim item text (symptom items are original paraphrases). Run the `humanizer` skill on any LLM-generated prose.
- **G5 I1 tone**: no streaks, no punishment language, no "you missed", no shame framing. Setbacks are normal flow (book's own principle).
- **G6 Validated**: all content passes JSON Schema + custom invariants before commit; validator exit code must be 0.
- **G7 Ids**: kebab-case, globally unique.
- **G8 Session skeleton** (from spec §12): every session = ritual checkpoints (symptom checklist, medication adherence, module review) + reading + in-session exercise + home practice + anticipate difficulties.
- **G9 Bundle**: `manifest.json` = `{schema_version, content_version, built_at, files:[{path, sha256}]}`; rebuild is deterministic for a pinned `content_version`.
- **G10 Toolchain**: commands run from `content/` via `env -u PYTHONPATH ./.venv/Scripts/python.exe` (host `PYTHONPATH` → Hermes venv shadows `rpds`, any jsonschema import dies with `ModuleNotFoundError: rpds.rpds`; ALWAYS unset it; MSYS: forward slashes for native tools).

---

## File Structure

```
adhd-cbt-app/
├── app/                      # Flutter app (M2+)
├── backend/                  # FastAPI (M1+)
├── content/
│   ├── README.md             # pipeline usage + authoring guide
│   ├── schema/
│   │   ├── session.schema.json
│   │   └── form.schema.json
│   ├── sessions/             # 13 files: 01-psycho-1.json ... 13-relapse.json
│   ├── forms/                # 8 files: symptom-checklist.json, medication-adherence.json,
│   │                         #   module-review.json, attention-gauge.json, problem-solving.json,
│   │                         #   thought-record.json, pros-cons.json, strategy-rating.json
│   ├── tools/
│   │   ├── validate.py
│   │   └── build.py
│   ├── tests/
│   │   ├── test_pipeline.py  # validator/builder unit tests
│   │   └── test_content.py   # structural tests over real content
│   ├── build/                # generated bundle (gitignored)
│   └── pyproject.toml        # pytest config
├── docs/research/2026-08-15-adhd-market.md   # Task 0 deliverable (market research)
└── docs/superpowers/plans/2026-08-15-m0-content-pipeline.md
```

---

### Task 0: Competitive & market research (gate before content authoring)

**Files:**
- Create: `docs/research/2026-08-15-adhd-market.md`

**Interfaces:**
- Consumes: spec `docs/superpowers/specs/2026-08-15-adhd-cbt-app-design.md` (locked decisions §2), seed sources: `https://add.org/adhd-tools-for-adults/` (ADDA) + `https://www.additudemag.com/mobile-apps-for-adhd-minds/` (ADDitude 25-app list, Feb 2026)
- Produces: market report consumed by user review; may produce spec amendments (positioning/pricing/content emphasis) — spec edits require user approval, never silent

**Route:** researcher role, `:free` models only (constitution: research → researcher).

- [ ] **Step 1: Run the research brief** (delegate to researcher, 3 parallel workstreams)

Brief (self-contained, already dispatched alongside this plan):
1. **Competitor inventory** — 8-12 adult-ADHD self-help apps (guided CBT programs + adjacent tools: Inflow, Shimmer, Done, Tiimo, Sunsama, etc.): platform, category, business model + price points, store rating, program structure. Seed: ADDi.org tools list. Every claim cited; unverifiable numbers marked UNVERIFIED. No fabrication.
2. **Deep-dive top 3-4 direct competitors** — program structure, content provenance, onboarding, retention mechanics (gamified vs calm), UX principles, monetization, user complaints from reviews.
3. **Market synthesis** — gaps vs our locked design (12-week guided, G2 completion-based, I1 anti-engagement, F2 privacy), differentiation vectors, pricing benchmark, risks (clinical-claim/store-review exposure, churn), 5 recommendations marked IMPLEMENT vs NOTE.

- [ ] **Step 2: Consolidate into `docs/research/2026-08-15-adhd-market.md`** and commit

```bash
git add docs/research/2026-08-15-adhd-market.md
git commit -m "docs(research): adult ADHD app market research"
```

- [ ] **Step 3: User review gate** — present report; any spec amendments (positioning, pricing anchor, module emphasis) go through explicit user approval before Task 1. STOP and wait for approval.

---

### Task 1: Monorepo layout + content toolchain

**Files:**
- Create: `app/README.md`, `backend/README.md` (one line each: "reserved for M2/M1")
- Create: `content/README.md` (usage: validate/build commands + authoring rules G1-G9)
- Create: `content/pyproject.toml`
- Modify: `.gitignore` (add `content/build/`, `content/.venv/`)

**Interfaces:**
- Consumes: nothing (repo exists from spec commit)
- Produces: `content/.venv` with `pytest` + `jsonschema`; working `pytest` invocation

- [ ] **Step 1: Write the failing smoke test**

`content/tests/test_pipeline.py`:
```python
def test_smoke():
    assert 1 + 1 == 2
```

- [ ] **Step 2: Run it to verify it fails (no venv yet)**

Run: `cd "C:/Users/eltun/Documents/adhd-cbt-app/content" && ./.venv/Scripts/python.exe -m pytest tests -q`
Expected: FAIL — `.venv/Scripts/python.exe` not found (bash: "No such file or directory")

- [ ] **Step 3: Create dirs, venv, install deps**

```bash
cd "C:/Users/eltun/Documents/adhd-cbt-app"
mkdir -p app backend content/schema content/sessions content/forms content/tools content/tests
echo "Reserved for M2 (Flutter app)." > app/README.md
echo "Reserved for M1 (FastAPI backend)." > backend/README.md
cd content
uv venv .venv
uv pip install --python ./.venv/Scripts/python.exe pytest jsonschema
```

`content/pyproject.toml`:
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
```

`.gitignore` (append):
```
content/.venv/
content/build/
```

- [ ] **Step 4: Run test to verify it passes**

Run: `./.venv/Scripts/python.exe -m pytest tests -q`
Expected: `1 passed`

- [ ] **Step 5: Commit**

```bash
git add .gitignore app/README.md backend/README.md content/README.md content/pyproject.toml content/tests/test_pipeline.py
git commit -m "chore(content): monorepo layout + uv toolchain"
```

---

### Task 2: JSON Schemas (session + form)

**Files:**
- Create: `content/schema/session.schema.json`
- Create: `content/schema/form.schema.json`

**Interfaces:**
- Consumes: nothing
- Produces: `session.schema.json` (validates every file in `sessions/`), `form.schema.json` (validates every file in `forms/`). Draft 2020-12. Field contracts consumed by Task 3 validator.

- [ ] **Step 1: Write the failing schema tests**

`content/tests/test_pipeline.py` (append):
```python
import json, pathlib

SCHEMA_DIR = pathlib.Path(__file__).resolve().parent.parent / "schema"

def load(name):
    with open(SCHEMA_DIR / name, encoding="utf-8") as f:
        return json.load(f)

def test_session_schema_rejects_missing_checkpoints():
    schema = load("session.schema.json")
    bad = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "x"}}
    errors = list(jsonschema_errors(bad, schema))
    assert any("checkpoints" in e for e in errors)

def test_session_schema_rejects_week_date_in_content():
    schema = load("session.schema.json")
    # schema itself can't reject dates; this asserts the invariant hook lives in the validator (Task 3).
    # Here we only assert the locale shape is enforced:
    bad_cp = {"id": "c1", "type": "reading", "title": {"en": "t"},
              "content": {"en": ["body"]}}
    # a checkpoint WITHOUT required 'type' must be rejected by schema:
    del bad_cp["type"]
    sess = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "x"},
            "checkpoints": [bad_cp]}
    errors = list(jsonschema_errors(sess, schema))
    assert any("type" in e for e in errors)
```

Add helper to the test file:
```python
import jsonschema

def jsonschema_errors(instance, schema):
    try:
        jsonschema.validate(instance, schema)
    except jsonschema.ValidationError as e:
        yield e.message
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_pipeline.py::test_session_schema_rejects_missing_checkpoints -q`
Expected: FAIL — `FileNotFoundError` (schema files don't exist yet)

- [ ] **Step 3: Write the schemas**

`content/schema/session.schema.json`:
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://adhdapp.local/schema/session.schema.json",
  "type": "object",
  "additionalProperties": false,
  "required": ["id", "order", "module", "title", "checkpoints"],
  "properties": {
    "id": {"type": "string", "pattern": "^[a-z0-9-]+$"},
    "order": {"type": "integer", "minimum": 1},
    "optional": {"type": "boolean", "default": false},
    "module": {"enum": ["psychoeducation", "organization_planning", "distractibility", "adaptive_thinking", "procrastination", "relapse_prevention"]},
    "title": {"$ref": "#/$defs/localized"},
    "checkpoints": {"type": "array", "minItems": 4, "items": {"$ref": "#/$defs/checkpoint"}}
  },
  "$defs": {
    "localized": {
      "type": "object", "additionalProperties": false, "required": ["en"],
      "properties": {"en": {"type": "string", "minLength": 1}}
    },
    "checkpoint": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "type", "title", "content"],
      "properties": {
        "id": {"type": "string", "pattern": "^[a-z0-9-]+$"},
        "type": {"enum": ["ritual", "reading", "exercise", "homework", "reflection"]},
        "title": {"$ref": "#/$defs/localized"},
        "formRef": {"type": "string", "pattern": "^form:[a-z0-9-]+$"},
        "requires": {"type": "array", "items": {"type": "string", "pattern": "^[a-z0-9-]+$"}, "uniqueItems": true},
        "content": {
          "type": "object", "additionalProperties": false, "required": ["en"],
          "properties": {
            "en": {"type": "array", "minItems": 1, "items": {"type": "string", "minLength": 1}}
          }
        }
      },
      "allOf": [
        {"if": {"properties": {"type": {"const": "exercise"}}},
         "then": {"anyOf": [{"required": ["formRef"]}, {"properties": {"content": {"minProperties": 1}}, "required": ["content"]}]}},
        {"if": {"properties": {"type": {"const": "ritual"}}},
         "then": {"required": ["formRef"]}}
      ]
    }
  }
}
```

`content/schema/form.schema.json`:
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://adhdapp.local/schema/form.schema.json",
  "type": "object",
  "additionalProperties": false,
  "required": ["id", "type", "title", "fields"],
  "properties": {
    "id": {"type": "string", "pattern": "^[a-z0-9-]+$"},
    "type": {"enum": ["symptom_checklist", "medication_adherence", "module_review", "attention_gauge", "problem_solving", "thought_record", "pros_cons", "strategy_rating"]},
    "title": {"type": "object", "additionalProperties": false, "required": ["en"],
              "properties": {"en": {"type": "string", "minLength": 1}}},
    "fields": {"type": "array", "minItems": 1, "items": {"$ref": "#/$defs/field"}}
  },
  "$defs": {
    "field": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "kind", "label"],
      "properties": {
        "id": {"type": "string", "pattern": "^[a-z0-9_-]+$"},
        "kind": {"enum": ["scale_0_3", "scale_0_100", "text", "textarea", "bool", "number"]},
        "label": {"type": "object", "additionalProperties": false, "required": ["en"],
                  "properties": {"en": {"type": "string", "minLength": 1}}},
        "options": {"type": "array", "items": {"type": "string"}}
      }
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_pipeline.py -q`
Expected: 3 passed (smoke + 2 schema tests)

- [ ] **Step 5: Commit**

```bash
git add content/schema content/tests/test_pipeline.py
git commit -m "feat(content): session + form JSON schemas"
```

---

### Task 3: Validator with custom invariants

**Files:**
- Create: `content/tools/__init__.py` (empty)
- Create: `content/tools/validate.py`

**Interfaces:**
- Consumes: `session.schema.json`, `form.schema.json`, `sessions/*.json`, `forms/*.json`
- Produces: `validate.validate() -> list[str]` (empty = OK) and `validate.main()` CLI (exit 0/1). Imported by tests and by Task 4 builder.

- [ ] **Step 1: Write the failing invariant tests**

`content/tests/test_pipeline.py` (append):
```python
import json, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.validate as V

def test_unknown_form_ref_detected(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    (tmp_path / "sessions").mkdir(); (tmp_path / "forms").mkdir()
    sess = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "t"},
            "checkpoints": [{"id": "c1", "type": "ritual", "title": {"en": "t"},
                             "content": {"en": ["x"]}, "formRef": "form:does-not-exist"}]}
    (tmp_path / "sessions" / "01.json").write_text(json.dumps(sess), encoding="utf-8")
    errs = V.validate()
    assert any("form:does-not-exist" in e for e in errs)

def test_iso_date_in_content_detected(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    (tmp_path / "sessions").mkdir(); (tmp_path / "forms").mkdir()
    sess = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "t"},
            "checkpoints": [{"id": "c1", "type": "reading", "title": {"en": "t"},
                             "content": {"en": ["Do this by 2026-09-01."]}}]}
    (tmp_path / "sessions" / "01.json").write_text(json.dumps(sess), encoding="utf-8")
    errs = V.validate()
    assert any("ISO date" in e for e in errs)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_pipeline.py::test_unknown_form_ref_detected -q`
Expected: FAIL — `ModuleNotFoundError: No module named 'tools'`

- [ ] **Step 3: Write the validator**

`content/tools/validate.py`:
```python
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_pipeline.py -q`
Expected: 5 passed

- [ ] **Step 5: Commit**

```bash
git add content/tools content/tests/test_pipeline.py
git commit -m "feat(content): validator with form-ref, requires, ISO-date invariants"
```

---

### Task 4: Bundle builder

**Files:**
- Create: `content/tools/build.py`

**Interfaces:**
- Consumes: `validate()` from Task 3 (build refuses to run on invalid content), all content files
- Produces: `content/build/manifest.json` + mirrored `schema/`, `forms/`, `sessions/` JSON; `build.build() -> dict` (manifest). Consumed by M5 OTA; format frozen here.

- [ ] **Step 1: Write the failing tests**

`content/tests/test_pipeline.py` (append):
```python
import hashlib, json, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.build as B

def test_build_produces_manifest_with_hashes(tmp_path, monkeypatch):
    monkeypatch.setattr(B, "CONTENT_DIR", tmp_path)
    monkeypatch.setattr(B, "OUT", tmp_path / "build")
    monkeypatch.setattr(B, "VERSION", "0.1.0")
    (tmp_path / "schema").mkdir(); (tmp_path / "forms").mkdir(); (tmp_path / "sessions").mkdir()
    (tmp_path / "forms" / "a.json").write_text('{"x": 1}', encoding="utf-8")
    m = B.build()
    assert m["content_version"] == "0.1.0"
    entry = [f for f in m["files"] if f["path"] == "forms/a.json"][0]
    assert entry["sha256"] == hashlib.sha256(b'{"x": 1}').hexdigest()
    assert (tmp_path / "build" / "manifest.json").exists()

def test_build_is_deterministic(tmp_path, monkeypatch):
    monkeypatch.setattr(B, "CONTENT_DIR", tmp_path)
    monkeypatch.setattr(B, "OUT", tmp_path / "build")
    (tmp_path / "schema").mkdir(); (tmp_path / "forms").mkdir(); (tmp_path / "sessions").mkdir()
    (tmp_path / "forms" / "a.json").write_text('{"x": 1}', encoding="utf-8")
    m1 = B.build(); m2 = B.build()
    assert m1["files"] == m2["files"]
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_pipeline.py::test_build_produces_manifest_with_hashes -q`
Expected: FAIL — `ModuleNotFoundError: No module named 'tools.build'`

- [ ] **Step 3: Write the builder**

`content/tools/build.py`:
```python
"""Assemble content/ into a versioned bundle with a sha256 manifest."""
import datetime
import hashlib
import json
import pathlib
import sys

import tools.validate as V

CONTENT_DIR = pathlib.Path(__file__).resolve().parent.parent
OUT = CONTENT_DIR / "build"
VERSION = "0.1.0"
SCHEMA_VERSION = "1.0.0"
BUNDLE_DIRS = ("schema", "forms", "sessions")


def _sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def build():
    errors = V.validate()
    if errors:
        for e in errors:
            print(f"ERROR: {e}")
        sys.exit(1)
    manifest = {
        "schema_version": SCHEMA_VERSION,
        "content_version": VERSION,
        "built_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "files": [],
    }
    OUT.mkdir(exist_ok=True)
    for d in BUNDLE_DIRS:
        for p in sorted((CONTENT_DIR / d).glob("*.json")):
            dest = OUT / d / p.name
            dest.parent.mkdir(exist_ok=True)
            dest.write_bytes(p.read_bytes())
            manifest["files"].append({"path": f"{d}/{p.name}", "sha256": _sha256(p)})
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    return manifest


if __name__ == "__main__":
    m = build()
    print(f"built {len(m['files'])} files -> {OUT}")
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_pipeline.py -q`
Expected: 7 passed

- [ ] **Step 5: Commit**

```bash
git add content/tools/build.py content/tests/test_pipeline.py
git commit -m "feat(content): versioned bundle builder with sha256 manifest"
```

---

### Task 5: Forms catalog (8 forms)

**Files:**
- Create: `content/forms/symptom-checklist.json`, `medication-adherence.json`, `module-review.json`, `attention-gauge.json`, `problem-solving.json`, `thought-record.json`, `pros-cons.json`, `strategy-rating.json`

**Interfaces:**
- Consumes: `form.schema.json` (Task 2)
- Produces: form ids referenced by sessions (Task 6-10) via `form:<id>`; consumed by Forms Engine (M3)

- [ ] **Step 1: Write the failing structural test**

`content/tests/test_content.py`:
```python
import json, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.validate as V

def test_forms_catalog_complete():
    forms = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.FORMS_DIR)}
    expected = {"symptom-checklist", "medication-adherence", "module-review",
                "attention-gauge", "problem-solving", "thought-record",
                "pros-cons", "strategy-rating"}
    assert expected <= set(forms)
    assert len(forms["symptom-checklist"]["fields"]) >= 19, "18 symptom items + total"

def test_forms_pass_validation():
    assert V.validate() == []
```

- [ ] **Step 2: Run to verify failure**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_content.py -q`
Expected: FAIL — forms missing

- [ ] **Step 3: Write the forms** (each validates against `form.schema.json`)

Form requirements (original phrasing, G4 — no APA/DSM verbatim):

| File | type | fields |
|---|---|---|
| `symptom-checklist.json` | symptom_checklist | 18 items `scale_0_3` (`s1`…`s18`; original paraphrases of inattention + hyperactivity/impulsivity domains, 9+9), 1 `scale_0_3` total-distress field |
| `medication-adherence.json` | medication_adherence | `prescribed_doses` number, `missed_doses` number, `triggers` textarea |
| `module-review.json` | module_review | `module` select (options = 6 module names), `worked_well` textarea, `difficulties` textarea |
| `attention-gauge.json` | attention_gauge | `task` text, `attention_minutes` number, `distraction_count` number, `notes` textarea |
| `problem-solving.json` | problem_solving | 6 steps as textarea: `problem`, `solutions`, `pros`, `cons`, `action_plan`, `review` |
| `thought-record.json` | thought_record | `situation` textarea, `automatic_thought` textarea, `thinking_error` select (options = errors catalog), `rational_response` textarea |
| `pros-cons.json` | pros_cons | `decision` text, `pros` textarea, `cons` textarea, `verdict` textarea |
| `strategy-rating.json` | strategy_rating | `strategy` text, `usefulness` scale_0_100, `why` textarea |

Sample to copy-paste shape (symptom-checklist.json — 3 items shown; write all 18 in execution):
```json
{
  "id": "symptom-checklist",
  "type": "symptom_checklist",
  "title": {"en": "Weekly symptom check"},
  "fields": [
    {"id": "s1", "kind": "scale_0_3", "label": {"en": "Careless mistakes in detail-heavy work"}},
    {"id": "s2", "kind": "scale_0_3", "label": {"en": "Difficulty sustaining attention in tasks"}},
    {"id": "s3", "kind": "scale_0_3", "label": {"en": "Not seeming to listen when spoken to directly"}},
    {"id": "total", "kind": "scale_0_3", "label": {"en": "Overall impact on my week"}}
  ]
}
```

- [ ] **Step 4: Run tests to verify pass**

Run: `./.venv/Scripts/python.exe -m pytest tests/test_content.py -q && ./.venv/Scripts/python.exe tools/validate.py`
Expected: 2 passed; `OK: 0 sessions, 8 forms`

- [ ] **Step 5: Commit**

```bash
git add content/forms
git commit -m "feat(content): forms catalog (checklist, adherence, review, gauge, problem-solving, thought record, pros-cons, strategy rating)"
```

---

### Task 6: Sessions 1-2 — Psychoeducation (pattern-setting)

**Files:**
- Create: `content/sessions/01-psycho-what-is-adhd.json`, `content/sessions/02-psycho-how-program-works.json`

**Interfaces:**
- Consumes: `session.schema.json`, forms `symptom-checklist`, `medication-adherence`, `module-review`
- Produces: the checkpoint pattern all later sessions follow (G8); session ids referenced nowhere else (engine picks up by directory scan)

**Step 1: Write the failing structural test**

`content/tests/test_content.py` (append):
```python
def test_session_skeleton_complete():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    for sid, s in sessions.items():
        types = [c["type"] for c in s["checkpoints"]]
        assert "ritual" in types, f"{sid}: no ritual checkpoint"
        assert "reading" in types, f"{sid}: no reading checkpoint"
        assert "exercise" in types, f"{sid}: no exercise checkpoint"
        assert "homework" in types, f"{sid}: no homework checkpoint"

def test_session_orders_unique():
    sessions = [json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)]
    orders = [s["order"] for s in sessions]
    assert len(orders) == len(set(orders)), "duplicate session orders"
    assert orders == sorted(orders), "session orders must be 1..N contiguous"
```

**Step 2: Run to verify failure** — Expected: FAIL (no sessions yet)

**Step 3: Write session 1 fully** — the exemplar. Structure (G8) + body (original, humanizer-processed, I1 tone, no dates):

`content/sessions/01-psycho-what-is-adhd.json`:
```json
{
  "id": "01-psycho-what-is-adhd",
  "order": 1,
  "module": "psychoeducation",
  "title": {"en": "Understanding ADHD"},
  "checkpoints": [
    {"id": "ritual-check", "type": "ritual", "title": {"en": "Weekly check-in"},
     "content": {"en": ["This is the first session, so your baseline matters. Answer as honestly as you can."]},
     "formRef": "form:symptom-checklist"},
    {"id": "ritual-meds", "type": "ritual", "title": {"en": "Medication check"},
     "content": {"en": ["Track what you were prescribed and any doses you missed this week."]},
     "formRef": "form:medication-adherence"},
    {"id": "read-adhd", "type": "reading", "title": {"en": "What ADHD is — and is not"},
     "content": {"en": [
       "ADHD is a real, biological condition, not a character flaw. It is not about intelligence, laziness, or willpower.",
       "The core difficulties are attention, impulsivity, and activity level — and they have been with you since childhood, even if the shape of them changed as you grew up.",
       "Symptoms alone are not a diagnosis. Diagnosis requires that these difficulties actually interfere with real parts of your life — work, school, relationships — and that they are not better explained by something else.",
       "The useful question for this program is not 'do I have ADHD?' but 'which situations are hardest for me, and what skills help there?'"
     ]}},
    {"id": "read-cbt-model", "type": "reading", "title": {"en": "The cycle this program targets"},
     "content": {"en": [
       "Years of struggling can teach a person to expect failure. That expectation shows up as negative automatic thoughts: 'I can't do this', 'I'll just do it later', 'it won't work anyway'.",
       "Those thoughts drive avoidance, avoidance erodes skills, and eroded skills produce more failures — a self-reinforcing loop.",
       "This program interrupts that loop. Medication (if you take it) reduces the core symptoms; the skills here give you ways to cope with what remains. Both together work better than either alone.",
       "You will not be graded, and there is no way to fall behind in a way that matters. Missing a session or a practice week is part of the process, not a failure of it."
     ]}},
    {"id": "ex-map", "type": "exercise", "title": {"en": "Map your hard situations"},
     "content": {"en": ["Write down three situations from the last month that felt overwhelming, and what you did in each."]},
     "formRef": "form:module-review"},
    {"id": "hw-read", "type": "homework", "title": {"en": "Home practice"},
     "content": {"en": [
       "Set up your calendar and a simple task list — one place where appointments and to-dos live. The next session builds on this.",
       "Each day, write down the two or three things that matter most, in the order you plan to do them."
     ]}},
    {"id": "ref-obstacles", "type": "reflection", "title": {"en": "Anticipate the week"},
     "content": {"en": ["What is likely to get in the way this week, and what will you do when it happens?"]}}
  ]
}
```

`content/sessions/02-psycho-how-program-works.json`: same skeleton; reading covers how the 12 sessions are structured, the weekly rhythm (check-in → skill → practice), and the middle-phase temptation to quit (book's own warning, original wording); exercise = choosing one goal for the program; homework = run the week with calendar + task list; reflection = same anticipatory prompt.

**Step 4: Run tests to verify pass** — `pytest tests -q && tools/validate.py` → 2 new sessions valid, all structural tests green.

**Step 5: Commit** — `git add content/sessions/01-*.json content/sessions/02-*.json && git commit -m "feat(content): psychoeducation sessions 1-2 (pattern exemplar)"`

---

### Task 7: Sessions 3-6 — Organization & Planning

**Files:** Create `content/sessions/03-org-calendar.json`, `04-org-priorities.json`, `05-org-problem-solving.json`, `06-org-papers.json`

**Interfaces:**
- Consumes: forms `module-review`, `problem-solving`
- Produces: the four org/planning sessions; checkpoint pattern per G8

**Step 1: Write the failing tests** (append to `test_content.py`):
```python
def test_module_coverage():
    sessions = [json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)]
    modules = {s["module"] for s in sessions}
    assert {"psychoeducation", "organization_planning", "distractibility",
            "adaptive_thinking", "relapse_prevention"} <= modules

def test_form_refs_resolve():
    forms = {p.stem for p in V._glob_json(V.FORMS_DIR)}
    sessions = [json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)]
    for s in sessions:
        for c in s["checkpoints"]:
            if "formRef" in c:
                assert c["formRef"].removeprefix("form:") in forms, f"{s['id']} {c['id']}"
```

**Step 2:** Run → FAIL (only 2 sessions exist).

**Step 3: Write the four sessions** — per-session checkpoint spec (bodies: original prose, humanizer-processed; same skeleton as Task 6):

- **03-org-calendar** (order 3, organization_planning): reading = one home for all commitments — calendar for appointments, task list for to-dos; "the system replaces scattered paper" principle; don't chase the perfect tool. exercise = enter this week's real appointments + tasks (no formRef; content instructions). homework = use calendar+list daily; bring nothing paper-based.
- **04-org-priorities** (order 4): reading = A/B/C priority ratings; small tasks first to build momentum; break big tasks into steps sized to your attention. exercise = take current list, assign A/B/C, break one A into steps (formRef: form:module-review). homework = daily A/B/C + one broken-down task.
- **05-org-problem-solving** (order 5): reading = 6-step problem-solving (define, brainstorm without judging, pros/cons, pick best imperfect option, plan steps, review). exercise = full run on a real problem (formRef: form:problem-solving). homework = one problem per week through the form.
- **06-org-papers** (order 6): reading = a simple workflow for incoming mail/papers: sort → act/decide → file or discard; a filing system with few categories. exercise = sort a real pile, define 3-5 categories (content instructions). homework = run the sort workflow once this week.

**Step 4:** `pytest tests -q && tools/validate.py` → all green (6 sessions, 8 forms).

**Step 5:** Commit — `git add content/sessions/03-*.json content/sessions/04-*.json content/sessions/05-*.json content/sessions/06-*.json && git commit -m "feat(content): organization & planning sessions 3-6"`

---

### Task 8: Sessions 7-8 — Reducing Distractibility

**Files:** Create `content/sessions/07-dist-attention-span.json`, `08-dist-environment.json`

**Step 1: Write the failing test** (append):
```python
def test_distractibility_sessions_reference_gauge_and_delay():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    s7 = sessions["07-dist-attention-span"]
    assert any(c["formRef"] == "form:attention-gauge" for c in s7["checkpoints"])
```

**Step 2:** Run → FAIL.

**Step 3: Write the two sessions** (skeleton per G8):

- **07-dist-attention-span** (order 7, distractibility): reading = attention span is not fixed; measure it on a "dreaded" task; the **distractibility delay** — work in chunks that match your span, then deliberately delay the moment of distraction; a short, timed break is planned, not an escape. exercise = gauge your span on one dreaded task now (formRef: form:attention-gauge). homework = run 3 chunked work sessions with the delay technique.
- **08-dist-environment** (order 8): reading = modify the environment so focus costs less: physical cues (one thing on the desk), digital triggers (notifications off, phone out of sight), a start ritual; "active ignoring" — a written list of intrusive thoughts to park, not fight. exercise = pick 3 environment changes for your main work spot (content instructions). homework = apply the 3 changes + park-list for a week.

**Step 4:** `pytest tests -q && tools/validate.py` → green.

**Step 5:** Commit — `git add content/sessions/07-*.json content/sessions/08-*.json && git commit -m "feat(content): distractibility sessions 7-8"`

---

### Task 9: Sessions 9-11 — Adaptive Thinking

**Files:** Create `content/sessions/09-think-cognitive-model.json`, `10-think-adaptive-thinking.json`, `11-think-rehearsal.json`

**Step 1: Write the failing test** (append):
```python
def test_thought_record_used_in_adaptive_thinking():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    used = [s["id"] for s in sessions.values()
            if any(c.get("formRef") == "form:thought-record" for c in s["checkpoints"])]
    assert "10-think-adaptive-thinking" in used and "11-think-rehearsal" in used
```

**Step 2:** Run → FAIL.

**Step 3: Write the three sessions**:

- **09-think-cognitive-model** (order 9, adaptive_thinking): reading = thoughts sit between situations and feelings; in ADHD the old failure narrative makes tasks feel bigger; the skill is noticing the thought before acting on it. exercise = re-read your Week-1 map (from session 1) and label the automatic thoughts in those situations (content instructions). homework = catch and write down 3 automatic thoughts during the week.
- **10-think-adaptive-thinking** (order 10): reading = the Thought Record: situation → automatic thought → thinking error → rational response; the common thinking errors catalog (all-or-nothing, catastrophizing, mind-reading, fortune-telling, should-statements, overgeneralization); a rational response is not forced optimism — it is the most accurate, useful thought available. exercise = complete a Thought Record for a real situation (formRef: form:thought-record). homework = two Thought Records this week.
- **11-think-rehearsal** (order 11): reading = rehearsal makes the skill automatic; run the full sequence under mild stress (a real deadline), then review what worked; self-coaching — talking yourself through a task the way you would coach a friend. exercise = full Thought Record with self-coaching out loud (formRef: form:thought-record). homework = keep two records + one self-coached task.

**Step 4:** `pytest tests -q && tools/validate.py` → green.

**Step 5:** Commit — `git add content/sessions/09-*.json content/sessions/10-*.json content/sessions/11-*.json && git commit -m "feat(content): adaptive thinking sessions 9-11"`

---

### Task 10: Sessions 12-13 — Procrastination (optional) + Relapse Prevention

**Files:** Create `content/sessions/12-proc-procrastination.json`, `content/sessions/13-relapse-prevention.json`

**Step 1: Write the failing test** (append):
```python
def test_optional_flag_and_relapse_closer():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    assert sessions["12-proc-procrastination"].get("optional") is True
    assert sessions["13-relapse-prevention"]["order"] == 13
```

**Step 2:** Run → FAIL.

**Step 3: Write the two sessions**:

- **12-proc-procrastination** (order 12, procrastination, `"optional": true`): reading = procrastination as cognitive avoidance — postponing because focus gets easier near the deadline; perfectionism ("it must be right") as a driver; the fix combines skills you already have: break the task down, set a realistic goal for ONE step, challenge the perfectionist thought. exercise = pros/cons of doing the task now vs later (formRef: form:pros-cons). homework = one dreaded task via breakdown + one rational response.
- **13-relapse-prevention** (order 13, relapse_prevention): reading = finishing the sessions is the start of self-directed practice; benefits compound with use; schedule a one-month review with yourself; identify the strategies that earned their place. exercise = rate each strategy's usefulness and note why (formRef: form:strategy-rating). homework = write your maintenance plan: calendar system, chunked work, thought record — and the first signs that tell you to restart them.

**Step 4:** `pytest tests -q && tools/validate.py` → green.

**Step 5:** Commit — `git add content/sessions/12-*.json content/sessions/13-*.json && git commit -m "feat(content): procrastination (optional) + relapse prevention sessions"`

---

### Task 11: Final validation, bundle build, tag

**Files:**
- Create: `content/README.md` usage section (validate/build commands, authoring rules summary)

**Step 1: Write the failing full-suite gate test** (append to `test_content.py`):
```python
def test_full_catalog_gate():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    assert len(sessions) == 13
    orders = sorted(s["order"] for s in sessions.values())
    assert orders == list(range(1, 14))

def test_bundle_build_green():
    import tools.build as B
    m = B.build()
    assert m["content_version"] == "0.1.0"
    assert len(m["files"]) == 13 + 8 + 2  # sessions + forms + schemas
```

**Step 2:** Run → FAIL (build/ is stale or missing).

**Step 3: Full pipeline run**

```bash
env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q
env -u PYTHONPATH ./.venv/Scripts/python.exe tools/validate.py
env -u PYTHONPATH ./.venv/Scripts/python.exe tools/build.py
git status --short
```

Expected: all tests pass; `OK: 13 sessions, 8 forms`; `built 23 files`; `content/build/` gitignored. Run `humanizer` review pass on all session bodies (spot-check 2 sessions per module for AI-isms).

**Step 4: Update content/README.md** with the pipeline usage (validate/build commands + G1-G9 rules).

**Step 5: Commit + tag**

```bash
git add content/README.md content/tests
git commit -m "feat(content): full 12-week catalog gate + bundle build green"
git tag v0.1.0-content
```

---

## Self-Review

1. **Spec coverage:** §4 components 2 (Forms Engine data) → Tasks 2,5 ✓ · content-as-data (E3) → Tasks 3-4 ✓ · 12-week program (§1) → Tasks 6-10 ✓ · G8 weekly ritual (§12 spec) → Task 6 pattern + G8 constraint ✓ · §7 invariant 2 (atomic OTA) is M5; M0 guarantees bundle integrity via sha256 ✓ · l10n (open item 5) → G3 + locale-keyed strings ✓
2. **Placeholder scan:** content-task bodies are structural specs (checkpoint trees + coverage requirements + exemplar) — deliberate; each task's test asserts the required structure, so "done" is checkable. No TBD/TODO. The 18 symptom items are enumerated by id but written at execution — bounded, test-asserted (minItems + 18-item test via form field count is NOT asserted; add to Task 5 Step 3: symptom-checklist must contain ≥19 fields — the `test_forms_catalog_complete` test only checks presence). **FIX inline:** Task 5 Step 1 test should assert `len(forms["symptom-checklist"]["fields"]) >= 19`.
3. **Type consistency:** `formRef` format `form:<id>` consistent across schema, validator, tests, content tasks ✓ · `build()` returns manifest dict used identically in tests and CLI ✓ · module enum values match content tasks ✓.

## Execution Handoff

Plan complete and saved. Two execution options:

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks; route via `coder` role, `:free` models per constitution; durable progress on the native Kanban board (`hermes kanban`, board `adhd-cbt-app`). **Task 0 runs first and is researcher-routed** (research → researcher); its report gates content authoring via user review.
2. **Inline Execution** — execute in this session with executing-plans, batch with checkpoints.

Content-authoring tasks (6-10): run prose through the `humanizer` skill; LLM-assisted drafting is fine, G4 verbatim-copy is not.
