# Art Gate A: Stardew-primary visual reset, 2026-10-12

**Decision:** NOT APPROVED. Prior CI scene was technically healthy but visually weak; no assets from an image generator should be treated as pixel art merely because they have a pixelated texture.

## Failure observed in real 1920x1080 engine screenshot

- Identical rigid cottage roof triangles and timber facades repeated in an empty lawn.
- Grass drawn as an even repeated background with few coherent clumps.
- Path edges remain strongly rectangular even when tile integrity passes.
- Large round tree blobs, flat rock shapes and geometric cave portal; no ecological variety.
- The new artist showcase shows placement/sharing works but does **not** look like a finished Stardew-inspired world.
- Existing character sheet has small boxy faces, weak walk/work poses and mismatched gear silhouettes.
- The visually competing pipelines are: tracked `assets/original/hero` with layered generated ORA; `assets/sprites` newer flat objects; old `assets/terrain.png`, `assets/objects.png` and generated legacy sheets; third-party Ninja CC0 selected terrain. Editing both hero art and prefab art independently produces drift.

## Reference hierarchy
- **Stardew Valley primary:** clustered 2-5 pixel groups, larger differentiated vegetation patches and appealing palette variation, readable character heads/hair/outfit, warmer roof/material contrasts, connected landscape composition.
- **Necesse secondary:** compact footprints, clear structures, workload-heavy village and high object density.
- **Graveyard Keeper tertiary:** directional warm forge/cave light and atmospheric stone, without painterly gradients or aggressive outlines.

Official reference media belongs outside original PixelTown sprite directories:
- https://www.stardewvalley.net/press/
- https://necessegame.com/presskit
Do not copy frames/pixels or commit screenshots as game assets.

## First verified alternative
Candidate **Ansimuz Tiny RPG Town** Free Pack, source: https://opengameart.org/content/rpg-town-pixel-art-assets (CC0 and redistribution allowed).
The asset review in CI uses the creator-published archive, inspects only PNGs, logs SHA256/size, and publishes a separate contact sheet plus source PNGs as a short-lived artifact. It does **not** silently import/ship these sprites: stylistic selection and scale still require manual visual comparison and user approval. The founder's newer Tiny RPG Fantasy free pack also states CC0: https://ansimuz.itch.io/tiny-rpg-town . Do not apply that grant to paid expansions.

## Pass boundaries and acceptance
One coherent slice: cottage + blacksmith + oak + readable ground/path edges + base villager + matching guard + enclosed cave corner. Keep the existing prefab/script architecture and live prototype. No giant scripted drawing overhaul, no automatic PR merge.
The old Art Gate remains FAILED until original or properly licensed polished art has been integrated and engine-screen captures reviewed at 1920x1080, 2560x1440, 3440x1440 village and 1080p/ultrawide cave.

Further CC0 source audits are linked from STYLE_REVIEW_BOARD.md. Neither alternative met the Stardew-first art target; no runtime replacement was made. Art Gate A remains FAILED.
