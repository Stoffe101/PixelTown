# PixelTown Art Assets: actual files committed to Git

**Status:** The current assets are provisional artistic candidates, not owner-approved release-quality artwork. However, they are **real PNG files version-controlled in this repository**, not content generated when the game starts.

- `assets/terrain.png` is the original 16×16 tile sheet used by `assets/terrain_paint_tileset.tres`.
- `assets/objects.png` contains simple starter props; their crop regions are represented by actual Godot `AtlasTexture` resources in scenes and prefabs.
- `assets/characters.png` and `assets/equipment.png` are older original exploratory sheets (retained for reference).
- `assets/original/hero/*.png` are separately addressable, original PixelTown building, cave, tree, construction and character textures.
- `art/source/architecture/*.ora` are committed editable layered OpenRaster masters for the hero PNGs, useful for later hand-polishing.
- `assets/third_party/ninja_adventure/*.png` contains a small, clearly identified **CC0** artwork subset from Pixel-boy and AAA. The provenance inventory remains in that directory. CC0 artwork is not relicensed as our proprietary work.
- `scenes/levels/village_layout.tscn`, `cave_layout.tscn` and `assets/terrain_paint_tileset.tres` contain **saved painted terrain and placed sprites**, editable in Godot without any generation step.

## Getting started

1. Check out `prototype/art-direction-v1-00b` in GitHub Desktop (the work is not yet merged into `main`).
2. Open `project.godot` with Godot 4.7.2. Do not run a Python generator or download a ZIP.
3. Edit `scenes/levels/village_layout.tscn` or `cave_layout.tscn`, and save.
4. Drag reusable prefabs from `scenes/props/` to place assets and paint directly in `PaintedTerrain`.
5. Hand-drawn originals should be placed under `assets/handmade/` with their `.aseprite` / layered masters under `art/handmade/` and committed normally.

For optional troubleshooting, run `powershell -ExecutionPolicy Bypass -File .\\setup-pixeltown.ps1` in the repository. It reports missing files instead of generating substitutes.

The `tools/art/` scripts are optional, **offline art-production/migration tools**. Running them intentionally can modify tracked PNGs and will appear as a real Git diff; their output is never required at runtime. The initial starter terrain was baked once into `.tscn` resources using `bake_starter_layout.gd`. It must not overwrite subsequent hand-painted artwork.

CI verifies that every scene-referenced texture exists **and is tracked in Git**, and renders saved scenes directly on both operating systems. See [artist guide](../docs/15_GODOT_EDITOR_ARTIST_GUIDE.md) and [asset evaluation](../docs/10_ASSET_PACK_AUDIT.md).
