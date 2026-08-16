"""Assemble content/ into a versioned bundle with a sha256 manifest."""
import datetime
import hashlib
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import tools.validate as V

CONTENT_DIR = pathlib.Path(__file__).resolve().parent.parent
OUT = CONTENT_DIR / "build"
VERSION = "0.2.0"
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
    print(f"OK: {len(m['files'])} files, content_version={m['content_version']}")
