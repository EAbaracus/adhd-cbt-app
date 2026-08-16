# Content Pipeline

This directory holds the app's content-as-data: JSON Schemas, the 12-week
session catalog, the reusable forms catalog, and the validator + bundle
builder that turn them into a versioned, integrity-checked bundle.

## Layout
- `schema/` — `session.schema.json`, `form.schema.json` (JSON Schema draft 2020-12)
- `sessions/` — one JSON file per session (13 sessions, order 1..13)
- `forms/` — one JSON file per form (8 forms)
- `tools/validate.py` — validate content against schemas + custom invariants
- `tools/build.py` — assemble `build/` bundle with a sha256 manifest
- `tests/` — pytest suite (schema, validator, bundle, catalog-gate tests)

## Commands (from `content/`, MSYS/git-bash)
Always run pytest with `env -u PYTHONPATH` — the host `PYTHONPATH` shadows
packages and breaks imports:
```
env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q
env -u PYTHONPATH ./.venv/Scripts/python.exe tools/validate.py
env -u PYTHONPATH ./.venv/Scripts/python.exe tools/build.py
```
`validate.py` exits non-zero on any error. `build.py` refuses to run on
invalid content and writes `build/manifest.json` + mirrored JSON. `build/` is
gitignored.

## Authoring rules (G1-G9)
- **G1** content-as-data: never hardcode session/form text in app code.
- **G2** completion-based progression: `order` is metadata only; do not embed
  calendar dates or week numbers in content (validator rejects ISO dates).
- **G3** localization: every user-facing string is a `{"en": "..."}` object;
  add locales as new keys, never replace `en`.
- **G4** no clinical verbatim: session/forms prose is original or paraphrased;
  never copy APA/DSM or published workbook text.
- **G7/G8** weekly rhythm: each session has ritual + reading + exercise +
  homework (+ optional reflection) checkpoints; ritual checkpoints carry the
  `form:symptom-checklist` and `form:medication-adherence` refs.
- **Invariants** enforced by `validate.py`: formRefs must resolve to a form;
  `requires` must reference a checkpoint in the same session; checkpoint ids
  unique within a session; no duplicate ids across the catalog; no ISO dates
  in content.
- **Schema change contract:** editing a schema is a breaking change — bump
  `SCHEMA_VERSION` in `tools/build.py` and update the validator/tests.
