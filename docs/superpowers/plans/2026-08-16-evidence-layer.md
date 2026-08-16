# Evidence Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a canonical source registry (`content/sources/`) and a checkpoint-level `evidence[]` layer that links clinical claims in new content to verified bibliographic sources, with validator-enforced integrity and minimal in-app footnote rendering.

**Architecture:** Two phases. Phase 1 adds `source.schema.json` + 10 source files + validator/bibliographic invariants + build inclusion, touching **zero session content**. Phase 2 adds the `evidence` field to `session.schema.json`, six new `read-evidence-*` checkpoints with locked EN/TR claim copy, evidence-resolution validation, and footnote rendering in the Flutter app.

**Tech Stack:** Python 3.11 (content pipeline: JSON Schema draft 2020-12, jsonschema lib, pytest), Flutter/Dart 3.12 (app), git-bash on Windows (MSYS).

**Spec:** `docs/superpowers/specs/2026-08-16-evidence-layer-design.md` (commit `df07701`). Approach 1, sections 1–5 user-approved.

## Global Constraints

- Mevcut 13 seansın metnine DOKUNULMAZ. Zenginleştirme yalnızca yeni `read-evidence-*` checkpoint'leri ekler (spec §2 karar 2, 3).
- `evidence` yalnızca yeni içerikte; `evidence.source` yalnızca `content/sources/` registry'sine referans verir (spec §2 karar 4).
- Positional/paragraph-index referans YOK (spec §2 karar 7).
- Bibliyografik invariant: journal-type (`rct`, `literature_review`, `meta_analysis`, `pilot_study`) → `doi` VEYA `pmid` en az biri (ikisi serbest); book-type (`clinical_manual`, `handbook`, `patient_workbook`, `school_intervention_guide`) → `isbn` zorunlu (spec §2 karar 12).
- `evidence` taşıyan checkpoint id'si `^read-evidence-` pattern'ine uymalı (spec §2 karar 13).
- `id` == dosya adı (stem); duplicate id reddedilir.
- Content komutları git-bash'te `env -u PYTHONPATH ./.venv/Scripts/python.exe ...` ile çalışır (content/README.md; host PYTHONPATH shadow'lar).
- Tüm testler: `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q` — content/ altında.
- `app/assets/content/` committed kopya; content/build/ gitignored. İçerik değişikliği sonrası ikisi de güncellenir (bootstrap + OTA manifest app/assets'ten okur; backend `content/build/`'i servis eder).
- Flutter: `C:/Users/eltun/flutter/bin/flutter.bat test --no-pub` (app/ altında).
- Faz 1 yeşil commit olmadan Faz 2 başlamaz (spec §9).
- Schema değişikliği = breaking change: `SCHEMA_VERSION` bump + `atomic_promote.dart` `_expectedSchema` eşleşmesi (spec §7 + `app/lib/content/atomic_promote.dart:10`).

---

## File Structure

**Phase 1 (registry):**
- Create: `content/schema/source.schema.json` — kaynak kayıt şeması
- Create: `content/sources/ramsay-rostain-2015.json`, `barkley-2015.json`, `safren-2010-cbt-rct.json`, `knouse-safren-2010.json`, `sprich-2016-adolescent.json`, `solanto-2008-mct.json`, `mitchell-2013-mindfulness.json`, `antshel-barkley-2015.json`, `kendall-braswell-1993.json`, `dupaul-stoner-2016.json`
- Modify: `content/tools/validate.py` — source validation + invariants
- Modify: `content/tools/build.py` — sources in bundle, version bump
- Create: `content/tests/test_sources.py` — registry invariants
- Modify: `content/tests/test_build.py` — build includes sources; `test_content.py` bundle count

**Phase 2 (enrichment):**
- Modify: `content/schema/session.schema.json` — checkpoint `evidence` field
- Modify: `content/tools/validate.py` — evidence resolution + convention invariant
- Modify: `content/sessions/01-psycho-what-is-adhd.json`, `04-org-priorities.json`, `08-dist-environment.json`, `12-proc-procrastination.json`, `13-relapse-prevention.json` — append `read-evidence-*` checkpoints
- Create: `content/tests/test_evidence.py` — evidence invariants
- Modify: `app/lib/engine/models.dart` — `Checkpoint.evidence` + `SourceInfo`
- Modify: `app/lib/content/content_runtime.dart` — `loadSources()`
- Modify: `app/lib/screens/session_screen.dart` — footnote rendering
- Modify: `app/lib/l10n/app_strings.dart` — footnote/citation card copy
- Modify: `app/lib/content/atomic_promote.dart:10` — `_expectedSchema` 1.1.0
- Create: `app/test/evidence_widget_test.dart` — footnote rendering test

---

## PHASE 1 — SOURCE REGISTRY

### Task 1: `source.schema.json` + 10 source files

**Files:**
- Create: `content/schema/source.schema.json`
- Create: `content/sources/*.json` (10 files)

**Interfaces:**
- Produces: `source.schema.json` — consumed by `validate.py` Task 2. Source file shape consumed by app `SourceInfo.fromJson` (Phase 2 Task 8).

- [ ] **Step 1: Write `content/schema/source.schema.json`**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://adhdapp.local/schema/source.schema.json",
  "type": "object",
  "additionalProperties": false,
  "required": ["id", "author", "year", "title", "publication",
               "source_type", "access_status", "evidence_role"],
  "properties": {
    "id":            {"type": "string", "pattern": "^[a-z0-9-]+$"},
    "author":        {"type": "string", "minLength": 1},
    "year":          {"type": "integer", "minimum": 1900},
    "title":         {"type": "string", "minLength": 1},
    "publication":   {"type": "string", "minLength": 1},
    "doi":           {"type": "string", "pattern": "^10\\.\\d{4,9}/\\S+$"},
    "pmid":          {"type": "string", "pattern": "^\\d{5,9}$"},
    "isbn":          {"type": "string", "pattern": "^(97[89])?\\d{9}[\\dX]$"},
    "source_type":   {"enum": ["clinical_manual", "handbook", "patient_workbook",
                               "rct", "literature_review", "meta_analysis",
                               "pilot_study", "school_intervention_guide", "other"]},
    "access_status": {"enum": ["verified_accessible", "paywalled", "blocked_404", "unverified"]},
    "evidence_role": {"enum": ["foundational_framework", "efficacy_evidence",
                               "mechanism", "assessment_reference",
                               "contextual_background", "population_extension"]},
    "note":          {"type": "string"}
  }
}
```

- [ ] **Step 2: Write the 10 source files** (spec §4 registry table; identifiers verified 2026-08-16)

`content/sources/safren-2010-cbt-rct.json`:
```json
{
  "id": "safren-2010-cbt-rct",
  "author": "Safren, S. A., Sprich, S., Mimiaga, M. J., Surman, C., Knouse, L., & Otto, M. W.",
  "year": 2010,
  "title": "Cognitive behavioral therapy vs relaxation with educational support for medication-treated adults with ADHD and persistent symptoms: A randomized controlled trial",
  "publication": "JAMA, 304(8), 875-880",
  "doi": "10.1001/jama.2010.1192",
  "pmid": "20736471",
  "source_type": "rct",
  "access_status": "verified_accessible",
  "evidence_role": "efficacy_evidence",
  "note": "Kullanici listesindeki 186352 URL'si MMWR makalesine cozuluyordu (reçeteli ilac ED basvurulari) - Safren RCT'si degil. Canonical kayit PMID 20736471 / DOI 10.1001/jama.2010.1192; [4]/[8]/[15]/[21] girdileri bu tek kayda dedupe edilir. NCT00118911."
}
```

`content/sources/barkley-2015.json`:
```json
{
  "id": "barkley-2015",
  "author": "Barkley, R. A. (Ed.)",
  "year": 2015,
  "title": "Attention-deficit hyperactivity disorder: A handbook for diagnosis and treatment (4th ed.)",
  "publication": "Guilford Press",
  "isbn": "9781462517725",
  "source_type": "handbook",
  "access_status": "verified_accessible",
  "evidence_role": "mechanism",
  "note": "Guilford sayfasinda dogrulandi (hardcover ISBN 9781462517725, Ekim 2014 basim; atif 2015)."
}
```

`content/sources/ramsay-rostain-2015.json`:
```json
{
  "id": "ramsay-rostain-2015",
  "author": "Ramsay, J. R., & Rostain, A. L.",
  "year": 2015,
  "title": "Cognitive behavioral therapy for adult ADHD: An integrative psychosocial and medical approach (2nd ed.)",
  "publication": "Routledge",
  "isbn": "9781135072186",
  "source_type": "clinical_manual",
  "access_status": "verified_accessible",
  "evidence_role": "foundational_framework",
  "note": "2nd ed basimi 2014-09-25 (Google Books); atif 2015. Taylor & Francis TOC + abstract dogrulandi; kitap metni erisilemez."
}
```

`content/sources/solanto-2008-mct.json`:
```json
{
  "id": "solanto-2008-mct",
  "author": "Solanto, M. V., Marks, D. J., Mitchell, K. J., Wasserstein, J., & Kofman, M. D.",
  "year": 2008,
  "title": "Development of a new psychosocial treatment for adult ADHD",
  "publication": "Journal of Attention Disorders, 11(6), 728-736",
  "doi": "10.1177/1087054707305100",
  "source_type": "pilot_study",
  "access_status": "verified_accessible",
  "evidence_role": "efficacy_evidence",
  "note": "Pre/post development study (n=30, kontrol grubu YOK) - randomized efficacy trial degil. CAARS inattentive p<.001, Brown ADD p<.001."
}
```

`content/sources/knouse-safren-2010.json`:
```json
{
  "id": "knouse-safren-2010",
  "author": "Knouse, L. E., & Safren, S. A.",
  "year": 2010,
  "title": "Current status of cognitive behavioral therapy for adult attention-deficit hyperactivity disorder",
  "publication": "Psychiatric Clinics of North America, 33(3), 497-509",
  "doi": "10.1016/j.psc.2010.04.001",
  "pmid": "20599129",
  "source_type": "literature_review",
  "access_status": "blocked_404",
  "evidence_role": "contextual_background",
  "note": "PMID/DOI Crossref+PubMed'de dogrulandi. Tam metin erisilemez; MVP'de cite edilmez."
}
```

`content/sources/sprich-2016-adolescent.json`:
```json
{
  "id": "sprich-2016-adolescent",
  "author": "Sprich, S., Safren, S. A., Finkelstein, D., Remmert, J. E., & Hammerness, P.",
  "year": 2016,
  "title": "A randomized controlled trial of cognitive behavioral therapy for ADHD in medication-treated adolescents",
  "publication": "Journal of Child Psychology and Psychiatry, 57(3), 275-283",
  "doi": "10.1111/jcpp.12549",
  "pmid": "26990084",
  "source_type": "rct",
  "access_status": "blocked_404",
  "evidence_role": "population_extension",
  "note": "Kullanici atfi 'J Clin Psychiatry 77(11):1449-1455' YANLIS - gercek yayin JCPP 57(3):275-283. Tam metin erisilemez; MVP'de cite edilmez."
}
```

`content/sources/mitchell-2013-mindfulness.json`:
```json
{
  "id": "mitchell-2013-mindfulness",
  "author": "Mitchell, J. T., McIntyre, E. M., English, J. S., Dennis, M. F., Beckham, J. C., & Kollins, S. H.",
  "year": 2013,
  "title": "A pilot trial of mindfulness meditation training for ADHD in adulthood: Impact on core symptoms, executive functioning, and emotion dysregulation",
  "publication": "Journal of Attention Disorders, 21(13), 1105-1120",
  "doi": "10.1177/1087054713513328",
  "source_type": "pilot_study",
  "access_status": "blocked_404",
  "evidence_role": "contextual_background",
  "note": "Kullanici atfi '17(2):110-119' YANLIS - gercek cilt/sayfa 21(13):1105-1120 (online 2013). Tam metin erisilemez; MVP'de cite edilmez."
}
```

`content/sources/antshel-barkley-2015.json`:
```json
{
  "id": "antshel-barkley-2015",
  "author": "Antshel, K. M., & Barkley, R. A.",
  "year": 2015,
  "title": "Psychosocial interventions in attention-deficit/hyperactivity disorder: Update",
  "publication": "Child and Adolescent Psychiatric Clinics of North America, 24(1), 79-97",
  "doi": "10.1016/j.chc.2014.08.002",
  "pmid": "25455577",
  "source_type": "literature_review",
  "access_status": "blocked_404",
  "evidence_role": "contextual_background",
  "note": "Kullanici atfi '2020, 29(3)' YANLIS - gercek kayit 2015 Update (PMID 25455577). Tam metin erisilemez; MVP'de cite edilmez."
}
```

`content/sources/kendall-braswell-1993.json`:
```json
{
  "id": "kendall-braswell-1993",
  "author": "Kendall, P. C., & Braswell, L.",
  "year": 1993,
  "title": "Cognitive-behavioral therapy for impulsive children (2nd ed.)",
  "publication": "Guilford Press",
  "isbn": "9780898620138",
  "source_type": "clinical_manual",
  "access_status": "blocked_404",
  "evidence_role": "foundational_framework",
  "note": "ISBN kullanici URL'sinden; Guilford 404. ISBN-10 kontrolu Faz 1'de yapilacak. Tarihsel/cocuk odakli; MVP'de cite edilmez."
}
```

`content/sources/dupaul-stoner-2016.json`:
```json
{
  "id": "dupaul-stoner-2016",
  "author": "DuPaul, G. J., & Stoner, G.",
  "year": 2016,
  "title": "ADHD in the schools: Assessment and intervention strategies (3rd ed.)",
  "publication": "Guilford Press",
  "isbn": "9781462526000",
  "source_type": "school_intervention_guide",
  "access_status": "verified_accessible",
  "evidence_role": "assessment_reference",
  "note": "Guilford sayfasinda dogrulandi (paperback ISBN 9781462526000). Yetiskin self-help disi; MVP'de cite edilmez."
}
```

- [ ] **Step 3: Verify schema validates all 10 files**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe -c "import json,jsonschema,pathlib; s=json.load(open('schema/source.schema.json')); [jsonschema.validate(json.load(open(p)),s) for p in pathlib.Path('sources').glob('*.json')]; print('OK')"` (from `content/`)
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add content/schema/source.schema.json content/sources/
git commit -m "feat(content): source registry — schema + 10 verified sources (Phase 1)"
```

---

### Task 2: `validate.py` — source validation + bibliographic invariants

**Files:**
- Modify: `content/tools/validate.py`

**Interfaces:**
- Consumes: `source.schema.json`, `content/sources/*.json` (Task 1)
- Produces: `validate()` extended — returns error list including source errors; consumed by `build.py` (Task 3) and `test_sources.py` (Task 4)

- [ ] **Step 1: Add SOURCES_DIR + source validation to `validate()`**

Add after the `forms`/`sessions` loading (keep existing logic intact):

```python
SOURCES_DIR = CONTENT_DIR / "sources"

SOURCE_BOOK_TYPES = {"clinical_manual", "handbook", "patient_workbook", "school_intervention_guide"}
SOURCE_JOURNAL_TYPES = {"rct", "literature_review", "meta_analysis", "pilot_study"}
DOI_RE = re.compile(r"^10\.\d{4,9}/\S+$")
PMID_RE = re.compile(r"^\d{5,9}$")
ISBN_RE = re.compile(r"^(97[89])?\d{9}[\dX]$")
```

Inside `validate()`, after the forms loop and before the sessions loop:

```python
    source_schema = _load_json(SCHEMA_DIR / "source.schema.json")
    sources = {p.stem: _load_json(p) for p in _glob_json(SOURCES_DIR)}

    for sid, source in sources.items():
        try:
            jsonschema.validate(source, source_schema)
        except jsonschema.ValidationError as e:
            errors.append(f"source {sid}: schema: {e.message}")
        if source.get("id") != sid:
            errors.append(f"source {sid}: id must match filename stem ({source.get('id')!r})")
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
```

- [ ] **Step 2: Run validator against current content**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe tools/validate.py` (from `content/`)
Expected: `OK: 13 sessions, 8 forms` (existing output; sources now validated silently — output line unchanged, keep `n_s`/`n_f` print but no source count needed; optionally append source count)

- [ ] **Step 3: Commit**

```bash
git add content/tools/validate.py
git commit -m "feat(content): validate source registry — id-stem, bibliographic invariants (Phase 1)"
```

---

### Task 3: `build.py` — sources in bundle + version bump

**Files:**
- Modify: `content/tools/build.py`

**Interfaces:**
- Consumes: `validate()` (Task 2)
- Produces: `build/manifest.json` including `sources/*.json`; `VERSION = "0.4.0"`, `SCHEMA_VERSION = "1.1.0"` — consumed by backend content API and app OTA.

- [ ] **Step 1: Update constants + bundle dirs**

```python
OUT = CONTENT_DIR / "build"
VERSION = "0.4.0"
SCHEMA_VERSION = "1.1.0"
BUNDLE_DIRS = ("schema", "forms", "sessions", "sources")
```

- [ ] **Step 2: Update `test_build.py` fixtures** — the two build tests create `schema/forms/sessions` tmp dirs; add `sources`:

```python
    (tmp_path / "sources").mkdir()
```

in both `test_build_produces_manifest_with_hashes` and `test_build_is_deterministic`.

- [ ] **Step 3: Update `test_content.py::test_bundle_build_green`**

```python
def test_bundle_build_green():
    import tools.build as B
    m = B.build()
    assert m["content_version"] == B.VERSION
    n_sources = len(list(B.CONTENT_DIR.joinpath("sources").glob("*.json")))
    assert len(m["files"]) == 13 + 8 + 2 + n_sources  # sessions + forms + schemas + sources
```

- [ ] **Step 4: Run full content test suite**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q` (from `content/`)
Expected: all pass (existing 21 + new)

- [ ] **Step 5: Run build**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe tools/build.py` (from `content/`)
Expected: `OK: 23 files, content_version=0.4.0` (13+8+2 sources = 23)

- [ ] **Step 6: Sync built bundle to `app/assets/content/`**

```bash
cd C:/Users/eltun/Documents/adhd-cbt-app
cp content/build/schema/*.json app/assets/content/schema/
cp content/build/forms/*.json app/assets/content/forms/
cp content/build/sessions/*.json app/assets/content/sessions/
cp content/build/sources/*.json app/assets/content/sources/
cp content/build/manifest.json app/assets/content/manifest.json
```

(app/assets/content is the committed copy the app bootstraps from; backend serves content/build/. Both must match.)

- [ ] **Step 7: Verify app asset integrity path still green**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q` (from `content/`) — already green; this step is the sync verification: `git status --short` should show new `app/assets/content/sources/` + modified manifest + schema files.

- [ ] **Step 8: Commit**

```bash
git add content/tools/build.py content/tests/test_build.py content/tests/test_content.py app/assets/content/
git commit -m "feat(content): include sources in bundle — v0.4.0, schema 1.1.0, sync app assets (Phase 1)"
```

---

### Task 4: `test_sources.py` — registry invariant tests

**Files:**
- Create: `content/tests/test_sources.py`

**Interfaces:**
- Consumes: `V.validate()`, `V._glob_json`, `V.SOURCES_DIR` (Task 2)

- [ ] **Step 1: Write the tests**

```python
import json, pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.validate as V


def test_sources_catalog_complete():
    sources = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SOURCES_DIR)}
    expected = {"ramsay-rostain-2015", "barkley-2015", "safren-2010-cbt-rct",
                "knouse-safren-2010", "sprich-2016-adolescent", "solanto-2008-mct",
                "mitchell-2013-mindfulness", "antshel-barkley-2015",
                "kendall-braswell-1993", "dupaul-stoner-2016"}
    assert expected <= set(sources)
    assert len(sources) == 10


def test_sources_pass_validation():
    assert V.validate() == []


def test_id_matches_filename_stem(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path)
    (tmp_path / "sources").mkdir()
    good = {"id": "a-2010", "author": "A", "year": 2010, "title": "T",
            "publication": "P", "source_type": "rct", "access_status": "blocked_404",
            "evidence_role": "efficacy_evidence", "doi": "10.1000/a.b"}
    (tmp_path / "a-2010.json").write_text(json.dumps(good), encoding="utf-8")
    bad = dict(good, id="b-2011")
    (tmp_path / "b-2011.json").write_text(json.dumps(bad), encoding="utf-8")
    errs = V.validate()
    assert any("id must match filename" in e for e in errs)


def test_journal_type_requires_doi_or_pmid(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path)
    (tmp_path / "sources").mkdir()
    base = {"id": "j-2010", "author": "A", "year": 2010, "title": "T",
            "publication": "P", "source_type": "rct",
            "access_status": "blocked_404", "evidence_role": "efficacy_evidence"}
    no_id = dict(base)
    (tmp_path / "j-2010.json").write_text(json.dumps(no_id), encoding="utf-8")
    errs = V.validate()
    assert any("needs doi or pmid" in e for e in errs)
    # both allowed
    both = dict(base, doi="10.1000/a.b", pmid="12345678")
    (tmp_path / "j-2010.json").write_text(json.dumps(both), encoding="utf-8")
    assert V.validate() == []


def test_bad_doi_format_rejected(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path)
    (tmp_path / "sources").mkdir()
    bad = {"id": "j-2010", "author": "A", "year": 2010, "title": "T",
           "publication": "P", "source_type": "rct", "access_status": "blocked_404",
           "evidence_role": "efficacy_evidence", "doi": "not-a-doi"}
    (tmp_path / "j-2010.json").write_text(json.dumps(bad), encoding="utf-8")
    errs = V.validate()
    assert any("invalid doi" in e for e in errs)


def test_book_type_requires_valid_isbn(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path)
    (tmp_path / "sources").mkdir()
    no_isbn = {"id": "b-1993", "author": "A", "year": 1993, "title": "T",
               "publication": "P", "source_type": "handbook",
               "access_status": "blocked_404", "evidence_role": "mechanism"}
    (tmp_path / "b-1993.json").write_text(json.dumps(no_isbn), encoding="utf-8")
    errs = V.validate()
    assert any("needs isbn" in e for e in errs)
    bad_isbn = dict(no_isbn, isbn="123")
    (tmp_path / "b-1993.json").write_text(json.dumps(bad_isbn), encoding="utf-8")
    errs = V.validate()
    assert any("invalid isbn" in e for e in errs)
```

- [ ] **Step 2: Run tests**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests/test_sources.py -v` (from `content/`)
Expected: all pass

- [ ] **Step 3: Run full suite**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q` (from `content/`)
Expected: all pass

- [ ] **Step 4: Commit**

```bash
git add content/tests/test_sources.py
git commit -m "test(content): registry invariants — catalog, id-stem, bibliographic (Phase 1)"
```

---

## PHASE 2 — ENRICHMENT

### Task 5: `session.schema.json` — checkpoint `evidence` field

**Files:**
- Modify: `content/schema/session.schema.json`

**Interfaces:**
- Produces: checkpoint `evidence` array shape consumed by `validate.py` (Task 6), session JSON files (Task 7), `Checkpoint.fromJson` (Task 8).

- [ ] **Step 1: Add `evidence` to checkpoint `$defs`**

Inside the `checkpoint` `$defs`, after the `"requires"` property, add:

```json
        "evidence": {
          "type": "array",
          "minItems": 1,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": ["source", "claim"],
            "properties": {
              "source": {"type": "string", "pattern": "^[a-z0-9-]+$"},
              "claim":  {"$ref": "#/$defs/localized"}
            }
          }
        },
```

(Existing `localized` $defs reused as-is. `additionalProperties: false` on the checkpoint already exists — `evidence` must be added to the `properties` block.)

- [ ] **Step 2: Validate current sessions still pass (schema change is additive)**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe tools/validate.py` (from `content/`)
Expected: `OK: 13 sessions, 8 forms` (no session uses `evidence` yet)

- [ ] **Step 3: Commit**

```bash
git add content/schema/session.schema.json
git commit -m "feat(content): checkpoint evidence field in session schema (Phase 2)"
```

---

### Task 6: `validate.py` — evidence resolution + convention invariant

**Files:**
- Modify: `content/tools/validate.py`

**Interfaces:**
- Consumes: `sources` dict (Task 2), `evidence` schema field (Task 5)
- Produces: evidence-resolution + `read-evidence-*` convention checks inside `validate()` — consumed by tests (Task 8).

- [ ] **Step 1: Add evidence checks inside the sessions loop**

In `validate()`, inside the existing `for sid, session in sessions.items():` loop, after the existing `for cp in session["checkpoints"]:` inner loop body's formRef/requires checks, extend the inner loop:

```python
        for cp in session["checkpoints"]:
            ref = cp.get("formRef")
            if ref is not None and ref.removeprefix("form:") not in forms:
                errors.append(f"session {sid} {cp['id']}: unknown formRef {ref}")
            for req in cp.get("requires", []):
                if req not in cp_ids:
                    errors.append(f"session {sid} {cp['id']}: requires unknown {req}")
            evidence = cp.get("evidence")
            if evidence is not None:
                if not cp["id"].startswith("read-evidence-"):
                    errors.append(
                        f"session {sid} {cp['id']}: evidence only on read-evidence-* checkpoints")
                for ev in evidence:
                    if ev.get("source") not in sources:
                        errors.append(
                            f"session {sid} {cp['id']}: unknown evidence.source {ev.get('source')!r}")
            for text in cp["content"]["en"]:
                if ISO_DATE_RE.search(text):
                    errors.append(f"session {sid} {cp['id']}: ISO date violates G2: {text!r}")
```

- [ ] **Step 2: Run validator (no sessions have evidence yet — should stay green)**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe tools/validate.py` (from `content/`)
Expected: `OK: 13 sessions, 8 forms`

- [ ] **Step 3: Commit**

```bash
git add content/tools/validate.py
git commit -m "feat(content): validate evidence resolution + read-evidence-* convention (Phase 2)"
```

---

### Task 7: Add the six `read-evidence-*` checkpoints

**Files:**
- Modify: `content/sessions/01-psycho-what-is-adhd.json`
- Modify: `content/sessions/04-org-priorities.json`
- Modify: `content/sessions/08-dist-environment.json`
- Modify: `content/sessions/12-proc-procrastination.json`
- Modify: `content/sessions/13-relapse-prevention.json`

**Interfaces:**
- Consumes: `evidence` schema (Task 5), `sources` registry (Task 1), validation (Task 6)
- Produces: enriched sessions consumed by `Checkpoint.fromJson` (Task 8). All new checkpoints are **appended** to the `checkpoints` array — existing checkpoint objects untouched (spec §2 karar 2, git-diff-verifiable).

**Claim copy (locked, spec §6 — DO NOT REWORD):**

- [ ] **Step 1: Append to `01-psycho-what-is-adhd.json` checkpoints array** (after the existing `ref-obstacles` object — add comma after its closing brace):

```json
    ,
    {"id": "read-evidence-combined", "type": "reading",
     "title": {"en": "What the research shows: skills plus medication", "tr": "Araştırma ne diyor: beceriler artı ilaç"},
     "content": {"en": ["Structured skills training can still help when medication is not enough."],
                 "tr": ["İlaç yetmediğinde yapılandırılmış beceri eğitimi yine de yardımcı olabilir."]},
     "evidence": [
       {"source": "safren-2010-cbt-rct",
        "claim": {"en": "For adults whose ADHD symptoms persist despite medication, adding structured CBT skills training can further reduce symptoms compared with relaxation and educational support.",
                  "tr": "İlaç tedavisine rağmen DEHB belirtileri süren yetişkinlerde yapılandırılmış BDT beceri eğitiminin eklenmesi, gevşeme ve eğitim desteğine kıyasla belirtileri daha fazla azaltabilir."}}
     ]},
    {"id": "read-evidence-biology", "type": "reading",
     "title": {"en": "What the research shows: the core domains", "tr": "Araştırma ne diyor: çekirdek alanlar"},
     "content": {"en": ["ADHD is broader than attention — it also shows up in how emotions and self-regulation are managed."],
                 "tr": ["DEHB yalnızca dikkatten ibaret değildir — duyguların ve öz-düzenlemenin yönetiminde de kendini gösterir."]},
     "evidence": [
       {"source": "barkley-2015",
        "claim": {"en": "ADHD affects core domains of attention, impulsivity, and activity regulation, with executive-function and emotional-regulation difficulties also relevant to clinical impairment.",
                  "tr": "DEHB dikkat, dürtüsellik ve hareketlilik düzenlemesi gibi çekirdek alanları etkiler; yürütücü işlev ve duygusal düzenleme güçlükleri de klinik işlevsellikle ilişkilidir."}}
     ]}
```

- [ ] **Step 2: Append to `04-org-priorities.json` checkpoints array** (after existing `ref-obstacles`):

```json
    ,
    {"id": "read-evidence-mct", "type": "reading",
     "title": {"en": "What the research shows: organizing skills", "tr": "Araştırma ne diyor: düzenleme becerileri"},
     "content": {"en": ["Organizing, planning, and time management can be trained as skills — and the training shows up in attention measures."],
                 "tr": ["Düzenleme, planlama ve zaman yönetimi birer beceri olarak eğitilebilir — ve eğitim, dikkat ölçümlerinde kendini gösterir."]},
     "evidence": [
       {"source": "solanto-2008-mct",
        "claim": {"en": "A group program focused on time management, organization, and planning showed significant pre-to-post improvement in inattention and executive-function measures in a small open study.",
                  "tr": "Zaman yönetimi, organizasyon ve planlama becerilerine odaklanan bir grup programı, küçük bir açık çalışmada dikkatsizlik ve yürütücü işlev ölçümlerinde öncesine göre anlamlı iyileşme gösterdi."}}
     ]}
```

- [ ] **Step 3: Append to `08-dist-environment.json` checkpoints array** (after existing `ref-obstacles`):

```json
    ,
    {"id": "read-evidence-ef", "type": "reading",
     "title": {"en": "What the research shows: executive function", "tr": "Araştırma ne diyor: yürütücü işlev"},
     "content": {"en": ["Planning, working memory, and self-regulation sit at the center of the ADHD picture — which is why skills training targets them directly."],
                 "tr": ["Planlama, çalışma belleği ve öz-düzenleme DEHB tablosunun merkezinde yer alır — beceri eğitiminin doğrudan bunları hedeflemesinin nedeni de budur."]},
     "evidence": [
       {"source": "barkley-2015",
        "claim": {"en": "Executive-function difficulties (planning, working memory, self-regulation) are central to ADHD's clinical picture; skills training targets these areas.",
                  "tr": "Yürütücü işlev güçlükleri (planlama, çalışma belleği, öz-düzenleme) DEHB'nin klinik tablosunun merkezindedir; beceri eğitimi bu alanları hedefler."}}
     ]}
```

- [ ] **Step 4: Append to `12-proc-procrastination.json` checkpoints array** (after existing `ref-obstacles`):

```json
    ,
    {"id": "read-evidence-implementation", "type": "reading",
     "title": {"en": "What the research shows: knowing vs doing", "tr": "Araştırma ne diyor: bilmek ile yapmak"},
     "content": {"en": ["Knowing what to do is not the hard part for most adults with ADHD — carrying it out is. Treatment works on that gap directly."],
                 "tr": ["DEHB'li yetişkinlerin çoğu için zor olan ne yapacağını bilmek değil, yapmaktır. Tedavi doğrudan bu boşluk üzerinde çalışır."]},
     "evidence": [
       {"source": "ramsay-rostain-2015",
        "claim": {"en": "Adults with ADHD often know what to do but struggle to carry it out; treatment emphasizes implementation strategies that make follow-through easier.",
                  "tr": "DEHB'li yetişkinler çoğu zaman ne yapacağını bilir ama uygulamakta zorlanır; tedavi, uygulamayı kolaylaştıran stratejilere önem verir."}}
     ]}
```

- [ ] **Step 5: Append to `13-relapse-prevention.json` checkpoints array** (after existing `ref-obstacles`):

```json
    ,
    {"id": "read-evidence-maintenance", "type": "reading",
     "title": {"en": "What the research shows: keeping gains", "tr": "Araştırma ne diyor: kazanımları korumak"},
     "content": {"en": ["Follow-up is part of the treatment itself — and the gains from skills training have been shown to hold months later."],
                 "tr": ["İzlem, tedavinin kendisinin bir parçasıdır — ve beceri eğitiminden elde edilen kazanımların aylar sonra da korunduğu gösterilmiştir."]},
     "evidence": [
       {"source": "ramsay-rostain-2015",
        "claim": {"en": "Follow-up and maintenance are part of the clinical treatment protocol.",
                  "tr": "İzlem ve bakım, klinik tedavi protokolünün parçasıdır."}},
       {"source": "safren-2010-cbt-rct",
        "claim": {"en": "In the trial, CBT responders maintained their gains at 6 and 12 months.",
                  "tr": "Çalışmada BDT yanıt verenler kazanımlarını 6 ve 12 ayda korudu."}}
     ]}
```

- [ ] **Step 6: Validate + run tests**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe tools/validate.py` then `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q` (from `content/`)
Expected: `OK: 13 sessions, 8 forms`; all tests pass

- [ ] **Step 7: Rebuild + sync to app assets**

```bash
cd C:/Users/eltun/Documents/adhd-cbt-app
env -u PYTHONPATH content/.venv/Scripts/python.exe content/tools/build.py
cp content/build/schema/*.json app/assets/content/schema/
cp content/build/forms/*.json app/assets/content/forms/
cp content/build/sessions/*.json app/assets/content/sessions/
cp content/build/sources/*.json app/assets/content/sources/
cp content/build/manifest.json app/assets/content/manifest.json
```

- [ ] **Step 8: Commit**

```bash
git add content/sessions/ app/assets/content/
git commit -m "feat(content): six read-evidence-* checkpoints with verified claims (Phase 2)"
```

---

### Task 8: `test_evidence.py` — evidence invariants

**Files:**
- Create: `content/tests/test_evidence.py`

**Interfaces:**
- Consumes: `V.validate()` (Task 6)

- [ ] **Step 1: Write the tests**

```python
import json, pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.validate as V


def test_evidence_sources_resolve():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    sources = {p.stem for p in V._glob_json(V.SOURCES_DIR)}
    for sid, s in sessions.items():
        for cp in s["checkpoints"]:
            for ev in cp.get("evidence", []):
                assert ev["source"] in sources, f"{sid} {cp['id']}: {ev['source']}"


def test_evidence_only_on_read_evidence_checkpoints():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    for sid, s in sessions.items():
        for cp in s["checkpoints"]:
            if "evidence" in cp:
                assert cp["id"].startswith("read-evidence-"), f"{sid} {cp['id']}"


def test_evidence_checkpoints_present():
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
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
    # G2/G4 guard: the pre-enrichment checkpoint ids are frozen; only
    # read-evidence-* additions may exist. (git diff is the real gate; this
    # is a regression tripwire against id renames.)
    sessions = {p.stem: json.load(open(p, encoding="utf-8")) for p in V._glob_json(V.SESSIONS_DIR)}
    frozen = {
        "01-psycho-what-is-adhd": {"ritual-check", "ritual-meds", "read-adhd", "read-cbt-model",
                                   "ex-map", "hw-read", "ref-obstacles"},
        "04-org-priorities": {"ritual-check", "ritual-meds", "read-abc", "ex-rate",
                              "hw-read", "ref-obstacles"},
        "08-dist-environment": {"ritual-check", "ritual-meds", "read-env", "ex-changes",
                                "hw-read", "ref-obstacles"},
        "12-proc-procrastination": {"ritual-check", "ritual-meds", "read-avoid", "ex-proscons",
                                    "hw-read", "ref-obstacles"},
        "13-relapse-prevention": {"ritual-check", "ritual-meds", "read-maintain", "ex-rate",
                                  "hw-read", "ref-obstacles"},
    }
    for sid, frozen_ids in frozen.items():
        ids = {c["id"] for c in sessions[sid]["checkpoints"]}
        assert frozen_ids <= ids


def test_unknown_evidence_source_rejected(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "sessions").mkdir(); (tmp_path / "forms").mkdir(); (tmp_path / "sources").mkdir()
    sess = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "t"},
            "checkpoints": [
                {"id": "read-evidence-x", "type": "reading", "title": {"en": "t"},
                 "content": {"en": ["x"]},
                 "evidence": [{"source": "does-not-exist",
                               "claim": {"en": "c", "tr": "c"}}]}]}
    (tmp_path / "sessions" / "01.json").write_text(json.dumps(sess), encoding="utf-8")
    errs = V.validate()
    assert any("does-not-exist" in e for e in errs)


def test_evidence_on_non_read_evidence_rejected(tmp_path, monkeypatch):
    monkeypatch.setattr(V, "SESSIONS_DIR", tmp_path / "sessions")
    monkeypatch.setattr(V, "FORMS_DIR", tmp_path / "forms")
    monkeypatch.setattr(V, "SOURCES_DIR", tmp_path / "sources")
    (tmp_path / "sessions").mkdir(); (tmp_path / "forms").mkdir(); (tmp_path / "sources").mkdir()
    (tmp_path / "sources" / "s-2010.json").write_text(json.dumps(
        {"id": "s-2010", "author": "A", "year": 2010, "title": "T", "publication": "P",
         "source_type": "rct", "access_status": "blocked_404",
         "evidence_role": "efficacy_evidence", "doi": "10.1000/a.b"}), encoding="utf-8")
    sess = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "t"},
            "checkpoints": [
                {"id": "read-old", "type": "reading", "title": {"en": "t"},
                 "content": {"en": ["x"]},
                 "evidence": [{"source": "s-2010", "claim": {"en": "c"}}]}]}
    (tmp_path / "sessions" / "01.json").write_text(json.dumps(sess), encoding="utf-8")
    errs = V.validate()
    assert any("read-evidence-" in e for e in errs)
```

- [ ] **Step 2: Run tests**

Run: `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests/test_evidence.py -v` (from `content/`)
Expected: all pass

- [ ] **Step 3: Commit**

```bash
git add content/tests/test_evidence.py
git commit -m "test(content): evidence resolution + convention + frozen checkpoint guard (Phase 2)"
```

---

### Task 9: App models — `SourceInfo` + `Checkpoint.evidence`

**Files:**
- Modify: `app/lib/engine/models.dart`

**Interfaces:**
- Produces: `SourceInfo` (fields: `id, author, year, title, publication, doi, pmid, isbn, sourceType, accessStatus, evidenceRole, note`), `Checkpoint.evidence: List<CheckpointEvidence>` where `CheckpointEvidence(source, claim: Map<String,String>)`. Consumed by `content_runtime.loadSources()` (Task 10) and `session_screen.dart` (Task 11).

- [ ] **Step 1: Add `SourceInfo` + `CheckpointEvidence` models** (append to `models.dart`)

```dart
/// Bibliographic source record (content/sources/<id>.json).
class SourceInfo {
  final String id;
  final String author;
  final int year;
  final String title;
  final String publication;
  final String? doi;
  final String? pmid;
  final String? isbn;
  final String sourceType;
  final String accessStatus;
  final String evidenceRole;
  final String? note;

  SourceInfo({
    required this.id,
    required this.author,
    required this.year,
    required this.title,
    required this.publication,
    this.doi,
    this.pmid,
    this.isbn,
    required this.sourceType,
    required this.accessStatus,
    required this.evidenceRole,
    this.note,
  });

  factory SourceInfo.fromJson(Map<String, dynamic> json) => SourceInfo(
        id: json['id'] as String,
        author: json['author'] as String,
        year: json['year'] as int,
        title: json['title'] as String,
        publication: json['publication'] as String,
        doi: json['doi'] as String?,
        pmid: json['pmid'] as String?,
        isbn: json['isbn'] as String?,
        sourceType: json['source_type'] as String,
        accessStatus: json['access_status'] as String,
        evidenceRole: json['evidence_role'] as String,
        note: json['note'] as String?,
      );

  /// Compact citation line for the footnote card, e.g.
  /// "Safren et al. (2010). JAMA, 304(8), 875-880."
  String citationLine() =>
      '$author ($year). $publication.';
}

/// One evidence entry on a checkpoint: a claim + the source it rests on.
class CheckpointEvidence {
  final String source;
  final Map<String, String> claim;

  CheckpointEvidence({required this.source, required this.claim});

  String claimFor(String locale) => claim[locale] ?? claim['en'] ?? '';

  factory CheckpointEvidence.fromJson(Map<String, dynamic> json) {
    final claimJson = (json['claim'] as Map?) ?? const {};
    return CheckpointEvidence(
      source: json['source'] as String,
      claim: {
        for (final e in claimJson.entries)
          if (e.value is String) e.key: e.value as String,
      },
    );
  }
}
```

- [ ] **Step 2: Add `evidence` to `Checkpoint`**

Add field + constructor param + fromJson/toJson:

```dart
  final List<CheckpointEvidence> evidence;

  // constructor:
  this.evidence = const [],

  // fromJson:
  evidence: (json['evidence'] as List?)
          ?.map((e) => CheckpointEvidence.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],

  // toJson:
  if (evidence.isNotEmpty)
    'evidence': evidence
        .map((e) => {'source': e.source, 'claim': e.claim})
        .toList(),
```

- [ ] **Step 3: Run model tests**

Run: `cd app && flutter test --no-pub test/engine_models_test.dart`
Expected: pass

- [ ] **Step 4: Commit**

```bash
git add app/lib/engine/models.dart
git commit -m "feat(app): SourceInfo + Checkpoint.evidence models (Phase 2)"
```

---

### Task 10: App content runtime — `loadSources()`

**Files:**
- Modify: `app/lib/content/content_runtime.dart`

**Interfaces:**
- Consumes: `SourceInfo` (Task 9)
- Produces: `ContentRuntime.loadSources() -> Map<String, SourceInfo>` consumed by `session_screen.dart` (Task 11).

- [ ] **Step 1: Add `loadSources()`**

```dart
  Map<String, SourceInfo> loadSources() {
    final dir = Directory('${root.path}/sources');
    if (!dir.existsSync()) return {};
    final out = <String, SourceInfo>{};
    for (final f in dir.listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path))) {
      final s = SourceInfo.fromJson(
          jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
      out[s.id] = s;
    }
    return out;
  }
```

Add the import: `import '../engine/models.dart';`

- [ ] **Step 2: Add a runtime test** (`app/test/content_runtime_test.dart` — follow existing fixture pattern; sources dir with one JSON, assert loadSources returns it keyed by id).

- [ ] **Step 3: Run runtime tests**

Run: `cd app && flutter test --no-pub test/content_runtime_test.dart`
Expected: pass

- [ ] **Step 4: Commit**

```bash
git add app/lib/content/content_runtime.dart app/test/content_runtime_test.dart
git commit -m "feat(app): loadSources in content runtime (Phase 2)"
```

---

### Task 11: Session screen — footnote rendering

**Files:**
- Modify: `app/lib/screens/session_screen.dart`
- Modify: `app/lib/l10n/app_strings.dart`
- Modify: `app/lib/content/atomic_promote.dart`

**Interfaces:**
- Consumes: `Checkpoint.evidence`, `SourceInfo` (Tasks 9–10)
- Produces: footnote UI behavior — consumed by widget test (Task 12).

- [ ] **Step 1: AppStrings — footnote + citation card copy**

Add to `app_strings.dart` (en + tr maps; check the tr map exists further in the file — add matching keys to both):

```dart
    'evidence_view_source': 'View source',
    'evidence_claim_label': 'What this rests on',
```

(TR: `'evidence_view_source': 'Kaynağı görüntüle'`, `'evidence_claim_label': 'Bunun dayandığı kaynak'`)

- [ ] **Step 2: `atomic_promote.dart` schema bump**

```dart
  static const _expectedSchema = '1.1.0';
```

- [ ] **Step 3: Session screen — render evidence markers after content**

In `session_screen.dart`, in the body Column after the content paragraph loop, add:

```dart
              if (cp.evidence.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing8),
                Wrap(
                  spacing: AppTheme.spacing8,
                  children: [
                    for (final ev in cp.evidence)
                      ActionChip(
                        label: Text(_tr('evidence_view_source')),
                        onPressed: () => _showEvidence(ev),
                      ),
                  ],
                ),
              ],
```

Add the `_showEvidence` method (a bottom sheet — calm, tertiary, no modal):

```dart
  void _showEvidence(CheckpointEvidence ev) {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    final sources = AppScope.of(context)?.sources ?? const <String, SourceInfo>{};
    final src = sources[ev.source];
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ev.claimFor(locale.name), style: AppText.body),
              const SizedBox(height: AppTheme.spacing16),
              if (src != null) ...[
                Text(src.citationLine(),
                    style: AppText.small.copyWith(color: AppColors.textSecondary)),
                Text(src.title, style: AppText.small),
              ],
              const SizedBox(height: AppTheme.spacing8),
              Text(_tr('evidence_claim_label'),
                  style: AppText.caption.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 4: Wire `sources` into `AppScope`**

`AppScope` needs a `sources` field populated from `ContentRuntime.loadSources()` at bootstrap. Check `app_scope.dart` for where `forms` is loaded and mirror it (`Map<String, SourceInfo> sources`).

- [ ] **Step 5: Run existing widget tests**

Run: `cd app && flutter test --no-pub test/session_screen_test.dart`
Expected: pass (existing tests unaffected — new UI only appears when `evidence.isNotEmpty`)

- [ ] **Step 6: Commit**

```bash
git add app/lib/screens/session_screen.dart app/lib/l10n/app_strings.dart app/lib/content/atomic_promote.dart app/lib/app_scope.dart
git commit -m "feat(app): footnote evidence chips + source card bottom sheet (Phase 2)"
```

---

### Task 12: Widget test — evidence rendering

**Files:**
- Create: `app/test/evidence_widget_test.dart`

**Interfaces:**
- Consumes: SessionScreen with evidence-bearing checkpoint (Task 11)

- [ ] **Step 1: Write the widget test** (mirror `session_screen_test.dart` fixtures)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/engine/models.dart';
import '../lib/screens/session_screen.dart';

void main() {
  testWidgets('evidence checkpoint shows source chip; tap opens card', (tester) async {
    final session = Session(
      id: 's1',
      order: 1,
      module: 'psychoeducation',
      title: 'T',
      checkpoints: [
        Checkpoint(
          id: 'read-evidence-combined',
          type: CheckpointType.reading,
          title: 'What the research shows',
          content: const ['Body'],
          evidence: [
            CheckpointEvidence(
              source: 'safren-2010-cbt-rct',
              claim: const {'en': 'Claim text', 'tr': 'İddia metni'},
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(home: SessionScreen(session: session)));
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('View source'), findsOneWidget);
    await tester.tap(find.text('View source'));
    await tester.pumpAndSettle();
    expect(find.text('Claim text'), findsOneWidget);
  });
}
```

Note: if SessionScreen requires AppScope/AppLocale ancestors, wrap with the same scaffolding `session_screen_test.dart` uses (check that file for the harness pattern and mirror it).

- [ ] **Step 2: Run the test**

Run: `cd app && flutter test --no-pub test/evidence_widget_test.dart`
Expected: pass

- [ ] **Step 3: Run full app test suite**

Run: `cd app && flutter test --no-pub`
Expected: all pass (existing 95 + new)

- [ ] **Step 4: Commit**

```bash
git add app/test/evidence_widget_test.dart
git commit -m "test(app): evidence footnote rendering widget test (Phase 2)"
```

---

## Self-Review Notes (run after all tasks)

1. **Spec coverage:** §4 registry → Tasks 1–4; §5 schema → Task 5; §6 claims → Task 7; §7 validator/build/tests → Tasks 2, 3, 6, 8; §7 app → Tasks 9–12; §8 testing → per-task; §9 phasing → Phase gates.
2. **Type consistency:** `SourceInfo` field names match `source.schema.json` snake_case mapping (`source_type`→`sourceType`); `CheckpointEvidence(source, claim)` matches schema `{source, claim}`; `citationLine()` used only in Task 11.
3. **Placeholder check:** all 10 source files have concrete verified identifiers; all 6 checkpoint JSON blobs carry locked claim copy; no "TBD".
