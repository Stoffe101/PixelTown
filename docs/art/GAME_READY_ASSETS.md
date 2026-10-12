# PixelTown artwork: placing and editing (asset usability pass)

Open `scenes/levels/premium_asset_gallery.tscn` to preview the separated sprite instances at real game scale.  A captured version appears in CI artifacts.

This pack **does not replace the approved cottage**. Use the existing `HouseSmall.tscn` and `assets/sprites/buildings/house_small.png` unchanged.

## How to place individual objects
1. Switch GitHub Desktop to `prototype/art-direction-v1-00b`, pull and open your Godot project.
2. In the 2D editor open `scenes/levels/village_layout.tscn` or `scenes/levels/cave_layout.tscn`.
3. Drag a `.tscn` from `scenes/buildings`, `scenes/environment`, `scenes/props`, or `scenes/caves` onto the `Objects` node. Duplicating instances with Ctrl+D preserves the one shared source texture.
4. Move and save with Ctrl+S. Do **not** change `scenes/world_art.gd` for scenery positions. If you want an object to block movement, inspect the authored `Obstacle/CollisionShape2D` child. Simulation agents use marker positions and do not yet pathfind around arbitrary obstacle colliders.
5. Editing `assets/sprites/environment/oak_tree.png` updates every `OakTree.tscn` instance; the same rule applies to all props and buildings.

## Animated characters and enemies

Use draggable scenes `scenes/characters/Villager.tscn`, `Guard.tscn` and `scenes/enemies/Slime.tscn`, `Bat.tscn`, `Spider.tscn`. These are AnimatedSprite2D nodes backed by a shared SpriteFrames `.tres`, and play automatically. Each native master PNG is exactly tiled, so no crop rectangles are needed:

| Asset | Cell size | Sheet grid | Row order (top to bottom) | Frames per row | Animations |
|---|---|---|---|---|---|
| Villager | 64×72 | 4×4 | down, left, right, up | 4 | idle_*, walk_* |
| Guard | 64×72 | 4×4 | down, left, right, up | 4 | idle_*, walk_* |
| Slime | 64×48 | 4×1 | bounce | 4 | idle, bounce |
| Bat | 96×64 | 4×1 | fly | 4 | idle, fly |
| Spider | 80×64 | 4×1 | walk | 4 | idle, walk |

All frame coordinates begin at top-left. Frames advance left to right, shared origin is bottom-center, no trim per frame, nearest-neighbor pixels. Example: `villager.sprite_frames` points to `assets/animations/villager_frames.tres`; select `walk_left` in AnimatedSprite2D Inspector. For a working character to change facing via gameplay code, call `play("walk_left")`; for an idle character call `play("idle_left")`. Existing legacy movement remains in the world renderer and is bridged to these newer uniform sheets.

## Terrain painting

- The live prototype village and cave still use `PaintedTerrain` with `assets/terrain_paint_tileset.tres` referencing `assets/terrain.png`. The latter has been replaced with 16×16 cozy-village/cave candidates while preserving every existing atlas position.
- Additional larger sheets are `assets/tilesets/village/village_terrain_32.png`, `village_paths_32.png`, and `assets/tilesets/cave/cave_floor_32.png`, `cave_wall_32.png`.
- Matching `.tres` TileSets use **32×32** grid and named manual-paint atlases. Create a separate `TileMapLayer`, set its Tile Set to the matching resource and paint. These 32px candidates have deliberately not been assigned automatic terrain-connectivity (Godot terrain peering-bit) rules yet, because the original illustrated concepts don't provide mathematically seamless border families. Review seams at normal gameplay zoom and correct source clusters before declaring 32px auto-tiling production-ready.

## Art editing, rights and visual QA

- The production sprite files here are *processed excerpts of the user-approved generated concept art*, with corrected alpha bounds and quantized native-pixel grids. They are not hand-painted original Aseprite masters. Keep the full concept reference files out of runtime folders.
- Real Aseprite masters should be authored and saved as `art/handmade/<category>/<asset>.aseprite`, then exported onto the existing target PNG path with the canonical exporter. Avoid changing dimensions without also changing the instance offset/collider and `art/production_assets.json` size.
- The cottage is different: it is the separately user-approved **CC0 Ansimuz adaptation**, not our newly generated concepts; its authorship and rights remain documented in `docs/art/COTTAGE_CC0_TRIAL.md`.
- Neither passing CI nor having an AnimatedSprite2D node proves polished motion. The concept frames are aligned and animated but still require animator review of foot plants, direction silhouettes and in-game visual consistency. Do not merge draft PR #4 without explicit owner approval.


### Action animations used by the live demo (2026-10-12)
- `villager_activity_sheet.png`: 256×144, native pixel cells **64×72**, four columns, two rows. Row 0 = `gather_down` with moving hoe; row 1 = `work_down` with moving hammer. The main simulation selects these while stationary at storage or the construction site. The separate wood icon follows the worker during carrying. Other directional activity variants still need artist approval/production.
- `guard_attack_right.png`: indexed PNG 128×72, two **64×72** spear action poses. The guard's nonlooping `attack_right` in `guard_frames.tres` uses idle, two strike frames, idle at 16 fps during the real combat hit window. `defend_right` shows a stationary stance between strikes. This prototype does not yet include directional attacks, deaths, or complete combat gameplay.
- Both files are artist-review candidates assembled at native sprite resolution from the approved concept characters and native-pixel tools. They are not layered Aseprite masters. No gameplay code contains generated pixel art.
