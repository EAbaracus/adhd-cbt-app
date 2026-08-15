def test_smoke():
    assert 1 + 1 == 2

import json, pathlib

SCHEMA_DIR = pathlib.Path(__file__).resolve().parent.parent / "schema"

def load(name):
    with open(SCHEMA_DIR / name, encoding="utf-8") as f:
        return json.load(f)

import jsonschema

def jsonschema_errors(instance, schema):
    validator = jsonschema.Draft202012Validator(schema)
    yield from (e.message for e in validator.iter_errors(instance))

def test_session_schema_rejects_missing_checkpoints():
    schema = load("session.schema.json")
    bad = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "x"}}
    errors = list(jsonschema_errors(bad, schema))
    assert any("checkpoints" in e for e in errors)

def test_session_schema_rejects_missing_type_in_checkpoint():
    schema = load("session.schema.json")
    # Provide 4 checkpoints to satisfy minItems, then remove 'type' from one
    cp1 = {"id": "c1", "type": "reading", "title": {"en": "t"}, "content": {"en": ["body"]}}
    cp2 = {"id": "c2", "type": "reading", "title": {"en": "t"}, "content": {"en": ["body"]}}
    cp3 = {"id": "c3", "type": "reading", "title": {"en": "t"}, "content": {"en": ["body"]}}
    cp4 = {"id": "c4", "title": {"en": "t"}, "content": {"en": ["body"]}}  # missing 'type'
    sess = {"id": "s1", "order": 1, "module": "psychoeducation", "title": {"en": "x"},
            "checkpoints": [cp1, cp2, cp3, cp4]}
    errors = list(jsonschema_errors(sess, schema))
    assert any("type" in e for e in errors)


def test_valid_session_validates():
    schema = load("session.schema.json")
    valid = {
        "id": "s-valid", "order": 1, "module": "psychoeducation", "title": {"en": "T"},
        "checkpoints": [
            {"id": "c1", "type": "ritual", "title": {"en": "t"}, "content": {"en": ["x"]},
             "formRef": "form:symptom-checklist"},
            {"id": "c2", "type": "reading", "title": {"en": "t"}, "content": {"en": ["x"]}},
            {"id": "c3", "type": "exercise", "title": {"en": "t"}, "content": {"en": ["x"]}},
            {"id": "c4", "type": "homework", "title": {"en": "t"}, "content": {"en": ["x"]}},
        ],
    }
    assert list(jsonschema_errors(valid, schema)) == []


def test_valid_form_validates():
    schema = load("form.schema.json")
    valid = {"id": "f-valid", "type": "module_review", "title": {"en": "T"},
             "fields": [{"id": "note", "kind": "textarea", "label": {"en": "L"}}]}
    assert list(jsonschema_errors(valid, schema)) == []


def test_form_schema_rejects_bad_kind():
    schema = load("form.schema.json")
    bad = {"id": "f-bad", "type": "module_review", "title": {"en": "T"},
           "fields": [{"id": "f1", "kind": "scale_0_5", "label": {"en": "L"}}]}
    errors = list(jsonschema_errors(bad, schema))
    assert any("scale_0_5" in e for e in errors)