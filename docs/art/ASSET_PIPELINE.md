# Asset production pipeline (draft)
1. In Aseprite create `art/handmade/<category>/name.aseprite` with real layers, no smoothing, alpha canvas and stable origin. Aseprite auto-export script uses official `--batch --sheet --data --format json-array` flags.
2. On Windows: `powershell -ExecutionPolicy Bypass -File .\\tools\\art_export\\export-all.ps1` (optionally set `ASEPRITE_EXE`). PNGs exported to matching `assets/handmade/<category>/name.png`; animated sources get frame JSON.
3. Create a reusable Sprite2D scene with `res://scripts/world/placeable_sprite.gd`, with centered=false, an offset of (-width/2,-height+foot_padding), Texture Filter=Nearest, and an authored StaticBody2D/CollisionShape2D child for obstructing objects.
4. Save the prefab in `scenes/buildings`, `scenes/environment`, `scenes/props` or `scenes/caves`. Place instances in `scenes/levels/village_layout.tscn` under Objects and commit the map. Do not write new position constants in scripts.
5. For painting use TileMapLayer and a project .tres TileSet. Starter candidate TileSet is manual-variant-only; actual terrain-connectivity patterns remain work.
6. Whenever source art changes, re-export only the PNG, Godot will reload the shared texture. If dimensions/pivot/collision change, adjust the prefab once. Avoid overriding the Texture in individual instances.
7. Run `python tools/art_export/validate_native_assets.py` and `python tools/ci/check_asset_dependencies.py` then Godot import/unit tests. Real CI screenshots are review evidence, not final approval.
