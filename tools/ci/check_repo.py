#!/usr/bin/env python3
"""Cheap repository invariants that should fail loudly before running Godot."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
REQUIRED = (
    "LICENSE",
    "CONTRIBUTING.md",
    "README.md",
    "project.godot",
    "scenes/main.tscn",
    "scenes/main.gd",
    "scenes/levels/village_layout.tscn",
    "scenes/levels/cave_layout.tscn",
    "assets/terrain_paint_tileset.tres",
    "setup-pixeltown.ps1",
    ".gitattributes",
    "docs/15_GODOT_EDITOR_ARTIST_GUIDE.md",
    "scenes/world_art.gd",
    "tools/art/build_art.py",
    "tools/art/validate_assets.py",
    "assets/README.md",
    "tests/ci_runner.gd",
    "tests/unit/display_contract_test.gd",
    "tests/visual/capture.gd",
    "docs/00_PROJECT_VISION.md",
    "docs/01_VILLAGE_AND_SYSTEMS.md",
    "docs/02_EXPEDITIONS_AND_COMBAT.md",
    "docs/03_ART_DIRECTION.md",
    "docs/04_PROTOTYPE_AND_ROADMAP.md",
    "docs/05_DECISIONS_AND_OPEN_QUESTIONS.md",
    "docs/06_TECHNICAL_AND_QA.md",
    "docs/07_CI_AND_DISPLAY.md",
)

def main() -> int:
    failures = [f"Missing required file: {name}" for name in REQUIRED if not (ROOT / name).is_file()]
    if not failures:
        license_text = (ROOT / "LICENSE").read_text(encoding="utf-8")
        if "All Rights Reserved" not in license_text:
            failures.append("ARR license marker missing")
        project_text = (ROOT / "project.godot").read_text(encoding="utf-8")
        for marker in ('mode="viewport"', 'aspect="expand"', 'scale_mode="integer"'):
            if marker not in project_text:
                failures.append(f"Missing pixel/ultrawide setting {marker}")
        workflow_text = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
        if "permissions:\n  contents: read" not in workflow_text:
            failures.append("Workflow must have read-only default permissions")
        if "3440 1440" not in workflow_text:
            failures.append("3440x1440 visual test missing from workflow")
    for failure in failures:
        print(f"FAIL {failure}", file=sys.stderr)
    if not failures:
        print(f"PASS repository contracts ({len(REQUIRED)} required files; ARR, display and CI safeguards)")
    return 1 if failures else 0

if __name__ == "__main__":
    raise SystemExit(main())
