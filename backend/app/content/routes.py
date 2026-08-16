"""Versioned content serving. Immutable manifest + traversal-safe file reads."""
import json
import pathlib

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import JSONResponse

from app.auth.deps import require_entitlement

router = APIRouter(prefix="/api/content", tags=["content"])

_ALLOWED_DIRS = {"schema", "forms", "sessions"}


def _build_dir(request) -> pathlib.Path:
    return pathlib.Path(request.app.state.content_build_dir)


@router.get("/manifest")
def manifest(request: Request, user: dict = Depends(require_entitlement)):
    p = _build_dir(request) / "manifest.json"
    if not p.exists():
        raise HTTPException(status_code=404, detail="manifest not found")
    return JSONResponse(json.loads(p.read_text(encoding="utf-8")))


@router.get("/file/{path:path}")
def file_(path: str, request: Request, user: dict = Depends(require_entitlement)):
    parts = pathlib.PurePosixPath(path).parts
    if len(parts) != 2 or parts[0] not in _ALLOWED_DIRS or not parts[1].endswith(".json"):
        raise HTTPException(status_code=400, detail="invalid path")
    p = _build_dir(request).joinpath(*parts)
    if not p.is_file():
        raise HTTPException(status_code=404, detail="file not found")
    return JSONResponse(json.loads(p.read_text(encoding="utf-8")))
