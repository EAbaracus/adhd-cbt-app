def test_smoke():
    assert 1 + 1 == 2

import json, pathlib

SCHEMA_DIR = pathlib.Path(__file__).resolve().parent.parent / "schema"

def load(name):
    with open(SCHEMA_DIR / name, encoding="utf-8") as f:
        return json.load(f)

import jsonschema

def jsonschema_errors(instance, schema):
    try:
        jsonschema.validate(instance, schema)
    except jsonschema.ValidationError as e:
        yield e.message

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