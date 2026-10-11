# PixelTown: Artist-friendly Godot layout workflow (Prototype 00B)

**Current stage:** movable Godot 2D level scenes + runtime simulation linked to placement markers. **Do not confuse this with a complete in-game building placement system.** All artwork remains under review and draft PR #4 stays unmerged.

## First-time installation on Windows

1. In GitHub Desktop, **Fetch origin**. The latest Art Pass is on branch `prototype/art-direction-v1-00b`, **not** `main`. From **Current Branch** choose it; if there are local changes, first use **Branch → Stash All Changes** (or commit work you want to keep). Do not blindly discard edits to `project.godot` or `main.tscn`. The Godot-generated `*.gd.uid` files are temporarily ignored, as this prototype references scripts by path. After switching, pull.
2. Install Python 3 and Godot **4.7.2**. Keep a local copy of the originally supplied **Godot Project V4.zip**, which contains the CC0 Ninja Adventure reference textures. The paid/restricted packs are not used.
3. Right-click `setup-pixeltown.ps1` and run with PowerShell, or from a terminal in the project folder run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup-pixeltown.ps1 -GodotExampleZip "D:\Assets\Godot Project V4.zip"
   ```

   The script verifies source file hashes, regenerates our original PNG sprites and layered OpenRaster masters, and prepares the selected CC0 terrain. **These preview PNGs must be generated once before opening the level scenes**. Rerunning the generator overwrites generated previews, so save manually edited artwork into `assets/handmade/` and source masters into `art/handmade/`.
4. Open `project.godot` in Godot. Let the import scan finish. In FileSystem, open **`scenes/levels/village_layout.tscn`** or **`scenes/levels/cave_layout.tscn`**.

## Place and reposition artwork visually

You can also expand **FileSystem → scenes → props** and drag any of the 21 prepared `.tscn` **prefabs** into the **Objects** node or viewport. They include the correct 1:1 texture, foot anchor and nearest-pixel filtering, so no atlas cropping is needed. Choose the cottage, storehouse, smithy, tree, cave wall or smaller props there. In the 2D scene viewport, turn on visible guides/grid as needed. Expand **Objects** in the Scene tree. Click `Cottage`, `Smithy`, `Storehouse`, `Tree01`, `MineralShrine` and move them with **W (Move tool)** or drag the move gizmo. The positions in the Inspector are saved in the scene file, not recreated from a list of hard-coded locations. Press **Ctrl+S** and **F6 (Run Current Scene)** to look at the placement alone, or **F5 (Run Project)** to see it with the dynamic background, active characters and HUD.

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

The GitHub branch tracks the **source generators and level files**, but to keep generated preview files from flooding GitHub Desktop the generated `assets/original/hero/*.png` and `art/source/architecture/*.ora` are temporarily ignored. **Run `setup-pixeltown.ps1` once before opening the editor scenes.** If Godot reports missing textures after switching branches, close the editor, run setup and reopen the project so import can complete. To make permanent original work, save a **new source** under `art/handmade/` and PNG export under `assets/handmade/`; these directories are intentionally NOT ignored and should be committed alongside scene changes. The setup script must never be rerun over those handmade paths.
