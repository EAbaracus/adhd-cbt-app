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
