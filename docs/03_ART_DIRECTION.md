# Art Direction v1.0: Original Modular Fantasy Pixel Art

**Status:** **Visual reference hierarchy approved** on 2026-10-11. Exact produced artwork and scale are NOT approved; review Prototype 00B in actual Godot screenshots.

## Accepted reference priority

1. **Necesse** (official presskit: https://necessegame.com/presskit): readability, normal top-down village scale, distinct silhouettes, modularity and sustainable pixel-art complexity.
2. **Graveyard Keeper** (official images: https://www.graveyardkeeper.com/copy-of-home): some atmosphere, forge warmth, believable materials, trees and torch accents. Do NOT attempt its full handcrafted complexity.
3. **Stardew Valley** (official media: https://www.stardewvalley.net/media/): character warmth, expressive hair/clothing, short readable motions.
4. **Original PixelTown identity:** artwork, maps, sprites, interactions, equipment and UI must be independent creations. Never trace, lift or republish reference-game assets.

This is **Art Direction v1.0**; do not casually restart the overall art debate. Technical choices can change on real-engine evidence.

## Chosen direction

The project should look like a **cozy, cute, whimsical, 2D pixel-art fantasy village** contrasted with a darker underground cave world. It should have consistent tiny storybook characters, readable buildings, environment activity and modest animations. The team specifically prefers pixel art over complex modeled/illustrated art because modular pixel sprites can be created and maintained with fewer resources, **but pixel art still requires craft**.

The player disliked some earlier AI-generated character references because their proportions looked strange. Avoid giant infant-like heads/eyes, uncanny faces, inconsistent anatomical scale or blurry faux-pixel rendering. Characters should look charming through recognizable silhouettes and behavior rather than exaggerated facial features.

## Influences, not asset sources

Littlewood: comfortable village mood and readable little structures.
Necesse: visually active settlement, labor and crafting loop.
Core Keeper: evocative underground environments and resource discovery.

These are examples to STUDY, not games to copy. Do not lift their copyrighted sprites, code, palettes wholesale or layout designs. Develop a distinctive, coherent pixel language appropriate to our own simulation.

## Provisional art-production specification

| Item | Starting hypothesis | Status |
| --- | --- | --- |
| World perspective | slightly angled-looking top-down art with visible building fronts on a **normal square tile grid**, four-direction movement; **not true isometric** | direction chosen; actual camera and proportions to test |
| Terrain tiles | 16×16 logical pixels | to test |
| Character sprite | **20×30 and 24×32** candidates in reusable 24×32 animation cells | compare in engine; 24×32 is provisional favorite |
| Structures | modular buildings roughly 3–6 tiles wide | to test |
| Character movement | four-direction walking, few-frame cycles | to test |
| Pixel presentation | nearest-neighbor texture sampling and practical integer scaling | intended |
| Village palette | friendly moss greens, earth browns, cream stone, blue water, amber forge light | direction |
| Dungeon palette | desaturated rock, torch amber, fungus/cave crystal accents and clear combat effects | direction |

Compare **two candidate sprite scales** in a real Godot scene before fixing dimensions. Do not build large animation frame sets before the base characters look convincing. Keep scale, overlays and palette consistent across village and caves.

## Maintainable production pipeline

The old `art/world_canvas.gd` rectangle-painter is retained as prototype history only. Prototype 00B creates **actual editable PNG sprite/tileset atlases** with `tools/art/build_art.py` (standard-library-only source master). `scenes/world_art.gd` renders terrain via Godot **TileMapLayer** and y-sorted buildings, props, characters and independently aligned gear via reusable **Sprite2D** atlas regions. See `assets/README.md` and [00B log](09_PROTOTYPE_00B.md).

- Square 16×16 terrain cells, orthographic camera and visible building fronts (not isometric).
- Common 24×32 animation grid with 20×30 versus 24×32 original character drawings; four directional roles, idle/walk/work/attack frames, aligned helmet/shield/sword overlays.
- Review 1440×810, 1920×1080, 2560×1440 and **3440×1440** at regular and zoomed camera settings. Extra ultrawide world space, not horizontal stretching.
- Moderate reusable grass variation, integrated roads, warm forge lights and cooler cave rocks. Low-noise depth and silhouettes, not decorative scatter or excessive effects.
- PNGs are generated from the source master and attached in CI until the owner accepts the art. **Passing CI is not art approval.**

## Artwork production strategy

1. Establish a **master sprite grid and a small common palette** before expanding.
2. Create **one base villager sprite and a guard** in the same proportions, with reusable hair, clothing and helmet/shield/sword overlays.
3. Create a small environment sheet: grass, path, dirt, tree, house, storage, workshop/smithy, cave portal, cave floors/walls and one enemy.
4. Implement minimal frame-based idle, movement, work and combat animations with visible feedback in engine.
5. Compare sprites in an actual living scene, not only on a concept sheet or heavily enlarged preview.
6. Reuse modular parts, recolors and procedural details where those genuinely preserve style.
7. Fix inconsistencies by adjusting original sprite pixels/templates. Never bulk-generate dozens of unrelated AI characters and assume they'll match.
8. Test at **1920×1080, 2560×1440 and 3440×1440**, with the two candidate character scales and realistic zoom. Verify ultrawide camera composition and sprite readability, not merely PNG dimensions.

**Production honesty:** terrain, simple buildings and effects are relatively feasible; unique animated characters and visible equipment variants require more effort; hundreds of monsters, elaborate directional combat animations and unrestricted equipment appearance permutations are NOT responsible first goals.

## What makes the world feel alive

Meaningful motion and consequences outweigh raw detail: a smith hammering, light spilling from the forge, villagers carrying resources, crops visibly growing, guards gearing up, torches lighting dungeon paths, enemies reacting to hits and loot returning to the village. Real actions should drive visual feedback, not decorative motion that misrepresents the simulation.

## First art feasibility test

Make a single composite pixel-art vertical slice with:
- one grassy clearing, a path, a tree and small house;
- a working forge/storage hut and cave entrance;
- a villager sprite with walk/carry animation;
- a guard with armor/weapon overlay;
- a matching underground room with a single enemy;
- consistent camera and palette across both views.

Review whether this can be recreated, modified and extended without turning into an asset-production bottleneck. If style consistency fails, reconsider tile/character sizing or a suitable compatible third-party art pack BEFORE scaling production.

## Asset licensing policy

The repository is public but its **original art, code and documentation are All Rights Reserved**. Any outside texture, sound, icon, tool or font must be tracked with source, author, exact license, modifications, usage constraints and proof of commercial compatibility. Never import assets simply because they appear in a game screenshot, an image search result or a GitHub repository. Third-party licenses override ARR for their own materials and should be kept distinct.

## Remaining art decisions

Exact camera framing/zoom (the square-grid angled-looking top-down direction is chosen), actual tile dimensions, villager facial details, combat sprite resolution, character equipment layers, outdoor/dungeon contrast, lighting system and sprite creation tool. These require working prototypes and user approval.
