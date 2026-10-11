# Prototype 00: Art, Camera and Activity Experiment

**2026-10-11 | Work-in-progress.** Source branch: `prototype/art-camera-pass1`. Do not mark Gate A or B complete merely because CI passes.

## Purpose

Prove that we can make **original** and maintainable small storybook-like pixel art for both the village and cave at 1920×1080, 2560×1440 and **3440×1440**. Compare two character-size candidates in a live Godot scene before locking a sprite template or undertaking a large art-production batch.

## Implemented in this pass

- `art/world_canvas.gd`: hand-authored procedural pixel composition with a **shared color palette and square logical grid**, including grassy clearing, winding paths, river/bridge, trees, shrubs, home, storage hut, forge, construction plot and cave mouth. Cave uses stone, torches, crystalline ore and one enemy. All are **original draft art made from source-drawn pixels**, not scraped or imported external art.
- `scenes/main.gd`: camera, two visual viewpoints, pause, two character sprite-size proposals (roughly 16×24 and 20×30 logical pixels), HUD diagnostic readout and mouse/keyboard navigation.
- `scripts/demo_simulation.gd`: miniature repeatable background simulation that transfers a fixed stock of **three** wood units from storage via a carrying villager to a building plot, then completes a tiny hut. Cave attack ticks update irrespective of which viewpoint is active. This does **not** implement a real construction interface or real expedition.
- `tests/unit/demo_simulation_test.gd`: repeatable material-accounting, completion and concurrent-background-tick checks.
- Updated visual CI produces actual Godot PNGs from both scene modes and both art scales and verifies all target pixel dimensions. **CI passing is not artistic sign-off.**

## Controls and review path

Run `project.godot` with Godot 4.7.2 and press Play. `Tab` switches village/cave; `1`/`2` switches candidate sprite scale; `Space` pauses time; `R` resets demo; wheel zooms; middle mouse drag pans. The cave can also be reached by clicking its mouth.

First inspect GitHub Actions PNG evidence at 1920×1080 vs 3440×1440, then review actual motion and UI readability locally on Windows. Observe small-size face/helmet/shield silhouettes and whether buildings/terrain have enough depth and texture without creating noise. Check that the worker appears to carry real wood and that there is visible progress at the actual plot.

## Art source and licensing

All artwork is authored as editable deterministic drawing instructions in `art/world_canvas.gd`, and is considered **original prototype art** under the repository's All Rights Reserved policy. No external asset pack, copied reference sprite, copyrighted game screenshot, or third-party font is shipped. The built-in Godot font is used for the temporary diagnostics overlay. Color and motif decisions are **exploratory**, not user-approved production style. If the look passes review, extract a curated sprite atlas and editable layered masters before expanding content.

## Known limitations and unfinished goals

- No user-approved art style or decided sprite scale yet. Current art is primitive-coded; editability exists as source code, **not yet pixel-editor sprite sheets or Aseprite/Krita masters**.
- Worker is a simple state machine, not a general job planner or pathfinder. It begins auto-building one designated structure, not an interactive player-placed blueprint.
- Cave is one small animated encounter, not an expedition; no floor selector, gear scores, actual equipment crafting, tactical orders, resource return or discovery unlock. No actual game economy.
- Character movement/attack directions are only limited animated front-facing drawings. Next iteration should improve directional poses, equipment overlays, shadows, collision/occlusion, lighting, character personality and building depth **only after screenshot critique**.
- CI checks engine health and image size, not whether artwork is beautiful or a scene has bad composition. Physical 3440×1440 monitor testing and a feel/playtest remain necessary.

## Acceptance gates before expansion

1. **Art Gate A, pending:** user sees actual Godot screenshots/videos of village + cave, at both scales and relevant resolutions, and accepts a specific cohesive direction.
2. **Activity Gate B, pending:** watch the actual worker carry materials, animate construction and produce a completed structure, then confirm it feels rewarding.
3. **Architecture before content:** only after agreement extract production art templates and add a player-placed blueprint work queue. Avoid speculative population/dungeon systems until the first full loop proves fun.
