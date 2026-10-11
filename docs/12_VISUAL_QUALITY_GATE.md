# Prototype 00B Visual Quality Gate (living report)

**2026-10-11 · Evaluation after real Godot renders · Art approval: FAIL/PENDING**

## Review criteria (more important than raw sprite count)

A playable village must read as **an inhabited place**, not a scatterplot of discrete premade objects. The main navigation paths, buildings, trees and workstations should form a believable clearing at normal zoom. Buildings must have individual purpose and genuine visual depth; the sprites need to share pixel density, light direction and palette value contrast. Cave rooms must feel enclosed and intentional. People need attractive, recognizable silhouettes and readable directional equipment. The user explicitly rejected the current flat, block-built appearance. Any improvement must be judged against this bar, not whether CI renders successfully.

## Review of actual 3440×1440 renders

- [Baseline, prior imported CC0 trial](https://github.com/Stoffe101/PixelTown/actions/runs/38153596007): repeated saturated grass, road band and inconsistent blocky original roof props. **Rejected.**
- [Refactored, quieter meadow + CC0 architecture/cave pass](https://github.com/Stoffe101/PixelTown/actions/runs/38156614365): actual village/cave at 1080p/1440p/3440 ultrawide and zoom variations. **Still below visual approval**.
- **Village:** quieter meadow is better, but giant repeated canopy shapes, generic buildings, hard/right-angle road tiles, empty spaces and limited building-specific work all make the world feel assembled. Roof colors/scale are inconsistent with some original props.
- **Cave:** cooler slate is better than the earlier brick-wall carpet, but the player mostly sees a flat repeating ground plane with a guard, enemy and scattered props. No legible wall height, chamber silhouette, route, meaningful lighting hierarchy or expedition staging.
- **Characters:** base villager/guard remain simplistic program-generated placeholders. Helmet, shield and weapons align technically, but do not meet the requested character appeal and personality.
- **Motion:** walking/carrying exists and is state-driven; the worker originally did not visibly hold actual wood. An art revision adds a dedicated wood-bundle sprite and ledger-driven carried/delivered counts. This is correct *simulation feedback*; it cannot substitute for proper animation.
- **Technical:** Linux/Windows import + tests and PNG dimensions were verified. No physically verified Windows ultrawide interaction/zoom feel or human sign-off yet.

## Art-team production next, in strict priority

1. **One hero building**: author a layered source-editable medieval smithy with distinctive stone foundation, perspective-correct wall depth, believable roof/smoke/chimney, furnace/anvil tools and separate inactive/active lighting. Test it in the village before drawing the other structures. Do not use a crop of an unrelated CC0 building as a permanent blacksmith.
2. **One human template**: proportioned villager + armored guard, both 20×30 and 24×32 candidates in the same scene; faces should read at normal zoom, not enlarged preview only. Add true four-direction idle/walk/carry/tool/attack poses and correctly occluded sword/shield layers.
3. **Proper ground construction**: ground 16×16 tiles need *transition families* not just random full-square choices. A 3×3 path corner/intersection set, shore edge, planted soil, tree roots and shadow at building foundations are minimum viability. Place detail in clusters with open space and a visual focal point.
4. **One real cave chamber**: an intentional traversable space with wall face/corners, warm torches, cooler shadows, environmental staging and a visible encounter objective. Keep floor visually quiet but not blank. Test 0x72's authored CC0 dungeon wall modules as one coherent alternate if the Ninja set lacks good cave walls.
5. **Scale/camera**: 3440×1440 must reveal meaningful scenery on either side of a centered playable area, not acres of repetitive turf. Compare zoom 1×/2× and real Windows player movement at actual monitor before locking 24×32.

## Accepted constraints

Do not reopen the overall Necesse readability / Graveyard Keeper atmosphere / Stardew warmth reference hierarchy. Do not import entire unrelated packs or copy commercial-restricted artwork. Do not build new village/dungeon mechanics merely to distract from poor art. *Fail the art gate when the art is weak.* Keep PR #4 draft and `main` unchanged until the owner approves the **actual rendered** scenes. CI is technical evidence, **not** aesthetic sign-off.

### Local build and review

```sh
python -m pip install pillow==11.3.0
python tools/art/build_art.py
python tools/art/validate_assets.py
python tools/art/import_ninja_cc0.py --zip "/local/path/Godot Project V4.zip"
python tools/art/curate_v4_houses.py
```

Open `project.godot` in Godot 4.7.2. F1 shows/hides temporary help; 1/2 compares current size candidates; Tab changes between village/cave. Your physical Windows test still matters, and none of these generated sprites are frozen as a final art pack.

## Latest owner-feedback checkpoint and current capture

The [latest verified Linux/Windows render run, 38157472174](https://github.com/Stoffe101/PixelTown/actions/runs/38157472174), places all four village landmarks within the normal 1920×1080 camera without clipping the cottage. The HUD is less intrusive, and carried vs. delivered wood are visibly linked to state. In 3440×1440 the environment extends horizontally without sprite stretching. Screenshot review still indicates **Art Gate A = FAIL**: generic/spaced-out structures, insufficient natural ground transitions, no properly layered Aseprite character artwork and an unconvincing cave chamber. Production-design acceptance must not be inferred from successful CI.
