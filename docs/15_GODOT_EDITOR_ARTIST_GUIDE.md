# PixelTown: Artist-friendly Godot layout workflow (Prototype 00B)

**Current stage:** movable Godot 2D level scenes + runtime simulation linked to placement markers. **Do not confuse this with a complete in-game building placement system.** All artwork remains under review and draft PR #4 stays unmerged.

## First-time installation on Windows

1. In GitHub Desktop, **Fetch origin**. The latest Art Pass is on branch `prototype/art-direction-v1-00b`, **not** `main`. From **Current Branch** choose it; if there are local changes, first use **Branch → Stash All Changes** (or commit work you want to keep). Do not blindly discard edits to `project.godot` or `main.tscn`. The Godot-generated `*.gd.uid` files are temporarily ignored, as this prototype references scripts by path. After switching, pull.
2. Install **Godot 4.7.2**. PixelTown's PNG sprite sheets, isolated prop art, CC0 dependency files and layered OpenRaster masters are **committed to the feature branch**. **You do not need Python or any asset ZIP to load/edit scenes.**
3. Optional: run `powershell -ExecutionPolicy Bypass -File .\\setup-pixeltown.ps1` to check that the committed art files exist. This script **does not regenerate or overwrite artwork**.
4. Open `project.godot` in Godot. Let the import scan finish. In FileSystem, open **`scenes/levels/village_layout.tscn`** or **`scenes/levels/cave_layout.tscn`**.

## Place and reposition artwork visually

You can also expand **FileSystem → scenes → props** and drag any of the 21 prepared `.tscn` **prefabs** into the **Objects** node or viewport. They include the correct 1:1 texture, foot anchor and nearest-pixel filtering, so no atlas cropping is needed. Choose the cottage, storehouse, smithy, tree, cave wall or smaller props there. To inspect **villagers and guards across all four facing directions and both sprite-size candidates**, open **`scenes/levels/character_studio.tscn`**. Each guard has a separate aligned equipment layer; click each Sprite2D to change its texture region or replace the source artwork. In the 2D scene viewport, turn on visible guides/grid as needed. Expand **Objects** in the Scene tree. Click `Cottage`, `Smithy`, `Storehouse`, `Tree01`, `MineralShrine` and move them with **W (Move tool)** or drag the move gizmo. The positions in the Inspector are saved in the scene file, not recreated from a list of hard-coded locations. Press **Ctrl+S** and **F6 (Run Current Scene)** to look at the placement alone, or **F5 (Run Project)** to see it with the dynamic background, active characters and HUD.

- **Duplicate a prop** by selecting a Sprite2D and pressing **Ctrl+D**. Rename it descriptively, then position it. The scene keeps instances independent; shared PNG art does not get duplicated in storage.
- **Replace a sprite's artwork** by selecting it, then in **Inspector → Texture** drag a replacement PNG from FileSystem. Original edited art should live at `assets/handmade/` so Git tracks it. Keep **Filter = Nearest** and **Scale = (1,1)**. Aesprite exports should retain transparent pixels, no smoothing or trimming.
- **Give an object an accurate foot anchor:** Sprite2D `Centered = false`, `Offset = (-width/2, -height)`. The node Position is the point where the building/tree meets the ground, so y-sorting remains coherent. For a 138×113 cottage use Offset `(-69, -113)`. Set **Y Sort Enabled** on the Objects parent, already configured.
- **Background terrain is currently generated at game runtime** and is not yet a fully hand-painted TileMap saved in these scenes. Static object placement *is* editable now; terrain and paths are still provisional and may change with the terrain-editor pass. You can still preview the structure/spacing in the editor.
- **Change an individual color/pixel shape:** right-click the PNG in FileSystem, **Show in File Manager**, open it in Aseprite, and **Save As** `assets/handmade/new_name.png`. It becomes a tracked original replacement. Source-editable master files are generated as `.ora` in `art/source/architecture`, which Krita can open with separate layers. Aseprite can open the exported PNG; create/save a native `.aseprite` file in `art/handmade/` to keep your changes. Do not overwrite generator output and expect it to survive regeneration.

## Move the simulation and important gameplay positions

Expand **Markers**. These are *placement handles*, not visible props. Moving these values changes runtime logic:

| Marker | Usage |
| --- | --- |
| `VillageLayout/Markers/Storage` | Where the wood-hauling worker begins and returns |
| `VillageLayout/Objects/ConstructionSite` | Destination of deliveries and final watch-hut position; **moving this sprite automatically moves the real construction destination** |
| `VillageLayout/Markers/GuardPost` | Guard / visible equipment standing position |
| `VillageLayout/Markers/CaveEntranceSpot` | Clickable cave transition position, move it to the actual door |
| `CaveLayout/Markers/GuardPost` | Expedition guard position |
| `CaveLayout/Markers/EnemySpawn` | Slime encounter position |

**Character previews:** `Objects/Guard` starts on the guard body sheet’s south-facing row and `Objects/GuardEquipment` is an aligned helmet/shield/sword overlay. They are two Sprite2D nodes and must share the same in-game position. **Do not move the worker or equipment nodes as if they were static decorations**. Their transforms are updated by game simulation on Play. Move the appropriate Marker2D instead, or the construction site itself. The code reads these markers at scene startup, including when restarting/replaying a screenshot. The cave/guard equipment slots stay aligned.

### The best division of work

**You and your girlfriend:** position buildings, terrain props and nature; choose art composition, create/modify PNGs and layered Aseprite masters, identify visual collisions/overlap. **Me:** turn your saved scene placements into the gameplay systems, AI, building jobs, cave encounters, new reusable props, automated tests and CI screenshots.

Suggested first pass: arrange **the cottage, storehouse and smithy** into a plausible settlement around short paths, then group trees/flowerbeds naturally. Keep the entrance and construction site clearly accessible. Save and commit the two `.tscn` scenes and any PNG/.aseprite files in the `handmade` directories. That gives me an exact, editable source of truth for the next gameplay pass.

## Clean GitHub Desktop and Godot logs

`.gitignore` covers import/cache files and generated `*.gd.uid` scripts. `.gitattributes` enforces LF for Godot/script text so a Windows checkout won't change every line merely from CRLF conversion. Godot often updates tracked `project.godot` or `main.tscn` when saving: inspect these diffs and **discard only changes you know you don't need**. Do not ignore either entire tracked file or use `skip-worktree`.

The unused legacy `art/world_canvas.gd` has been removed from the feature branch (it produced the integer-division/unused-parameter warnings in your screenshot). After switching branches and letting Godot reimport, the old script should no longer load. If Godot still shows old warnings, close Godot and reopen the project from the feature branch; confirm the script path shown in the individual error.

This is a practical authoring workflow, not permanent locking of camera scale or production art style. No major art change will be merged without your approval.

## Troubleshooting: where are my art assets?

All required PNGs, tilesets, level scenes and initial layered source masters are version-controlled. When you clone/pull the feature branch, opening Godot **must work directly**. `setup-pixeltown.ps1` only validates presence and will report a broken checkout rather than hide the error. Add any new art source under `art/handmade/` and PNGs under `assets/handmade/`, or edit the existing source master deliberately and commit its matching export.

## Character art and animation workflow

The full character sheets are generated as `assets/original/hero/inhabitants.png` and `guard_equipment.png`, with layered originals in `art/source/architecture/inhabitants.ora` and `guard_equipment.ora`. Open `scenes/levels/character_studio.tscn` in Godot to compare 16×24 and 20×30 sprite candidates, all four directions, and the equipment overlay. The sheets have **24×32 frame cells**; columns 0–7 are small, columns 8–15 large. Within a candidate, frames 0–3 are idle/walk, 4–5 are distinct work poses, 6–7 are strike poses. Directions occupy rows 0–3 for the worker and 4–7 for the guard. Gear rows are 0–3 in the same direction order. CI verifies that working/attacking frames differ and overlays are nonempty.

To hand-polish, create a new native Aseprite layered master in `art/handmade/` and export a transparent PNG to `assets/handmade/` using exactly the same cell grid. Assign that PNG to the appropriate Sprite2D Texture in the scene. Do not edit the generated source exports in place because rerunning the art generation script replaces them.
