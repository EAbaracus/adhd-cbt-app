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
