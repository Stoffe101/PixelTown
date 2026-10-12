#!/usr/bin/env python3
"""Release-blocking check: ALL Godot art is an actual Git-tracked file.

No optional generator, personal ZIP, Action cache, or renderer-time sprite
construction may be required to load an editable level after a clean checkout.
"""
from __future__ import annotations
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REQUIRED = [
    "assets/terrain.png", "assets/objects.png", "assets/characters.png",
    "assets/equipment.png", "assets/atlas.json",
    "assets/terrain_paint_tileset.tres",
    "assets/third_party/ninja_adventure/tileset_floor.png",
    "assets/third_party/ninja_adventure/tileset_interior_floor.png",
    "assets/third_party/ninja_adventure/tileset_village_abandoned.png",
    "assets/third_party/ninja_adventure/tileset_wall_simple.png",
    "assets/third_party/ninja_adventure/PROVENANCE.json",
    "scenes/levels/village_layout.tscn", "scenes/levels/cave_layout.tscn",
]
HERO_NAMES = (
    "cave_gate", "cave_wall", "cottage", "smithy", "storehouse",
    "mature_tree", "inhabitants", "guard_equipment", "construction_site",
    "watch_hut", "ancient_altar",
)
for name in HERO_NAMES:
    REQUIRED.extend((f"assets/original/hero/{name}.png",
                     f"art/source/architecture/{name}.ora"))

REF = re.compile(r'res://(assets/[^"\'\s\])}]+)')
def main() -> int:
    tracked = set(subprocess.check_output(
        ["git", "ls-files", "-z"], cwd=ROOT
    ).decode().split("\x00"))
    referenced: set[str] = set(REQUIRED)
    for pattern in ("scenes/**/*.tscn", "assets/**/*.tres", "scenes/**/*.gd"):
        for path in ROOT.glob(pattern):
            if not path.is_file():
                continue
            text = path.read_text(encoding="utf-8")
            referenced.update(REF.findall(text))
    failures=[]
    for name in sorted(referenced):
        if not (ROOT / name).is_file():
            failures.append(f"MISSING: {name}")
        elif name not in tracked:
            failures.append(f"NOT VERSION CONTROLLED: {name}")
    renderer=(ROOT/"scenes/world_art.gd").read_text(encoding="utf-8")
    if "TileMapLayer.new(" in renderer or "_make_tiles(" in renderer:
        failures.append("RUNTIME ART GENERATION: world_art.gd constructs terrain")
    for scene in ("village_layout.tscn","cave_layout.tscn"):
        path=ROOT/"scenes/levels"/scene
        if path.exists() and "tile_map_data" not in path.read_text(encoding="utf-8"):
            failures.append(f"NO SAVED PAINTED TERRAIN: {path.name}")
    if failures:
        print("\n".join("ART CONTRACT FAIL: "+x for x in failures),file=sys.stderr)
        return 1
    print(f"PASS: {len(referenced)} artwork/resource dependencies exist and are tracked")
    print("PASS: two scene-owned painted terrains, no runtime world painter")
    return 0
if __name__ == "__main__":
    sys.exit(main())
