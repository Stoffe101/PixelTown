# PixelTown Godot/Aseprite artist guide, candidate pass (2026-10-12)

**Status:** draft branch only. The new native-pixel images are unapproved art candidates, not commercial-quality sign-off.

## Placing scenery, no coding
1. In GitHub Desktop select `prototype/art-direction-v1-00b`, pull and open `C:\Users\Skrra\Documents\Projects\PixelTown\project.godot` with Godot 4.7.2.
2. Open `scenes/levels/village_layout.tscn`, expand `Objects`, and drag `scenes/environment/OakTree.tscn` into Objects. Move it with the gizmo, duplicate with Ctrl+D, then Ctrl+S.
3. Drag prefabs from `scenes/buildings`, `scenes/environment`, `scenes/props` or `scenes/caves`. Each has a foot-aligned origin, nearest texture filter and a physical CollisionShape2D child. Enable `show_placement_guides` in the Inspector for a 16px-grid footprint outline.
4. The `Objects` parent should have Y Sort Enabled. Scene instance positions and Inspector overrides persist. The running demo dynamically moves Worker/Guard sprites: edit `Markers` for those locations, not the animated sprites.
5. Open `scenes/levels/artist_showcase.tscn` for multiple separate prefab instances referencing a single source. F6 runs just the scene. Existing village and cave layout files remain untouched.

## Shared prefab updates
Five OakTree instances refer to the same `res://assets/sprites/environment/oak_tree.png` resource. Open that PNG in Aseprite, change pixels and save with the **same file name**: Godot will reimport it and all five update. Changing the source `OakTree.tscn` also updates inherited (unoverridden) properties. A moved instance or local Modulate override retains its local setting. Use Inspector Revert on overrides to inherit shared values again. The live Aseprite save/reimport step must be verified on your PC; CI checks shared scene texture identity, instance independence and shapes.

## Aseprite pipeline
Save **real layered** `.aseprite` masters under `art/handmade/<category>/name.aseprite` and use layers `outline`, `base`, `light`, `details`, `equipment_front/back` as appropriate. Use native canvas pixels, transparent RGBA, nearest-neighbor sampling, 16x16 world tiles and bottom-foot anchors. No AI illustration downscaling or pixel smoothing.
Run `powershell -ExecutionPolicy Bypass -File .\tools\art_export\export-all.ps1` on Windows. If Aseprite isn't on PATH, set `ASEPRITE_EXE` to its executable or pass `--exe`. The source `art/handmade/environment/oak_tree.aseprite` exports to `assets/handmade/environment/oak_tree.png`. Multi-frame art gets Aseprite JSON metadata. To use a newly exported PNG instead of the draft PNG, change the base OakTree prefab **once**, not every placed instance. Existing `.ora` editable hero masters remain under `art/source/architecture`; no fake `.aseprite` files were created.

## Terrain
Existing `PaintedTerrain` TileMapLayers in village and cave are real saved editor paint, not code-generated at startup. The new `assets/tilesets/village/village_ground_16.tres` has 32 **manually selectable** native 16px grass, dirt, cobble and soil variants. Add/select a TileMapLayer, set its Tile Set to this resource, use the paint tool; don't replace established terrain blindly. Complete edge autotile rules/shore transitions are **not yet included**.

## Work division and limits
You can build compositions directly in editor, and your girlfriend can author/replace art with Aseprite. Gameplay scripts read saved scenes and their markers. Collision shapes are authored; the existing non-physics demo movement does not yet use navigation avoidance. Final art style, directional character masters, autotile connectivity, collision sizes and physical Windows/ultrawide review remain pending. Do not merge PR #4 until approved.
