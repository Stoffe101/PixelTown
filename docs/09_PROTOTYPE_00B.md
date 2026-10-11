# Prototype 00B: Art Direction v1.0 and modular sprite production

**2026-10-11 · Draft feature PR · Awaiting the owner's art approval.** The accepted *direction* is distinct from acceptance of individual sprites, proportions, visuals or camera feel.

## Accepted reference hierarchy and non-copying policy

1. **Necesse** is the primary benchmark for readable terrain, character-to-building scale, modularity and a production complexity we can maintain.
2. **Graveyard Keeper** influences restrained warmth, forge mood, building and roof materials, vegetation and atmospheric caves. It is not an achievable mandate to reproduce its detail everywhere.
3. **Stardew Valley** inspires friendly inhabitant silhouettes, hairstyles, clothing identity and concise activity animations.
4. **PixelTown itself** must remain original and recognizable, with its living village + autonomous adventuring identity.

Official pages reviewed: https://necessegame.com/presskit , https://www.graveyardkeeper.com/copy-of-home , https://www.stardewvalley.net/media/ . No screenshot, pixel, sprite or third-party art was imported. All implemented assets are original, proprietary and All Rights Reserved.

## Implemented technical/art pipeline

- `tools/art/build_art.py`: original deterministic, editable Python-standard-library pixel master. Produces actual PNG sheets and JSON regions (no external dependencies).
- `assets/terrain.png`: 256×64, **16×16** logical tile slots; grass variations, paths/water, cave floors/walls.
- `assets/objects.png`: 512×256 reusable original art: cottage, storage, blacksmith, cave mouth, tree, blueprint/finished hut, well, bush, crate, torch, mushrooms, crystals and slime.
- `assets/characters.png`: 384×256 with 24×32 cell slots, two **20×30 vs 24×32** artwork candidates, four directional rows per role, idle/walk/work/attack slots.
- `assets/equipment.png`: 384×128; guard helmet/armor/shield/sword drawn independently from the body, using matching frame coordinates and foot anchors.
- `assets/atlas.json`: explicit, stable source regions and frame metadata.
- `scenes/world_art.gd`: an actual Godot **TileMapLayer** uses terrain atlas tiles; separately instanced **Sprite2D** atlas sprites use bottom-foot anchors and **y-sort**. The old rectangle-drawn `art/world_canvas.gd` is no longer the renderer (retained for comparison/history).
- `scenes/main.gd` keeps mouse pan/zoom, village/cave switching, pause and reset. The wood transport/construction-state test and cave encounter simulation are preserved rather than rewritten.

The PNG files are **generated, not committed** while art is awaiting approval. CI creates them on Linux and Windows and uploads the true PNG assets as review artifacts. Local usage: `python tools/art/build_art.py`, then `python tools/art/validate_assets.py`, then open `project.godot`. Both commands use the standard library. After visual approval, commit chosen master PNGs and consider layered OpenRaster/Aseprite editing for hand polishing. See `assets/README.md`.

## Verification and review matrix

Run deterministic state unit tests plus sprite-atlas geometry and nonempty-frame checks, then render from Godot itself at 1440×810, 1920×1080, 2560×1440 and 3440×1440, village and cave views, and both size candidates. Capture two integer camera zooms, including at least a close-up of character body/equipment placement. Attach original baseline comparisons to the PR/QA notes once screenshots are reviewed. CI PNG dimensions alone do **not** judge beauty or physical ultrawide monitor sharpness.

Evidence links and findings should be appended below after the verified CI run rather than invented in advance.

### Pending human review

- Are the cottage, storage and forge recognizably different and sufficiently dimensional rather than geometric blocks?
- Does outdoor terrain blend naturally, and are plants/trees cohesive without visual clutter?
- Is the cave stylistically consistent yet distinct in lighting, clarity and hazards?
- Do the 20×30 and 24×32 body/helmet/shield overlays read at **actual gameplay zoom** on 16:9 and 3440×1440?
- Is four-direction movement believable, and are work/attack poses actually triggered by actions?
- Does zooming/panning keep pixels crisp, with no jitter, clipping or pointer-coordinate mistakes?

## Known limitations

This is still an art review candidate, not certified Necesse-level work and not an approved production sprite standard. Procedural authoring of PNG sheets is a transitional **source-editable master**, not permission to represent finished sprites using thousands of rectangles at runtime. The actual worker is a demo that automatically builds one plot, not an interactive blueprint work queue. Cave combat is a simple repeating proof, not real expeditions. Full equipment crafting, cave-floor locks/GS, gear combinations, injuries, full pathfinding, audio and save/loading are deferred. A physical Windows 3440×1440 playtest remains necessary.

**Art Gate A status: awaiting approval.** Keep this PR **draft**, regardless of passing engine/CI checks.

## Uploaded-pack audit and real-engine integration trial (2026-10-11)

Seven supplied ZIP archives were inventoried, including original art, format/animation dimensions, supplied license documents, source files and official published license references. See [10_ASSET_PACK_AUDIT.md](10_ASSET_PACK_AUDIT.md) for the exact pack comparison, rejected candidates, provenance policy and release recommendation. The actual per-file CSV and visual contact sheets are available to the project owner as separate audit artifacts.

**Selected live experiment:** a pinned Pixel-boy/AAA Ninja Adventure CC0 subset, imported from its official Godot V4 sample (four PNGs, integrity checked against exact SHA256). The environment tiles, foliage/cave entrance and original PixelTown guard/work demo now render together; all other candidate packs remain unintegrated. This is **not a decision to ship the complete Ninja Adventure pack**. Local setup must run `python tools/art/build_art.py` and `python tools/art/import_ninja_cc0.py --zip "/path/to/Godot Project V4.zip"` before opening Godot. CI uses the pinned read-only creator checkout.

**Actual [first trial run](https://github.com/Stoffe101/PixelTown/actions/runs/38153025846):** Linux and Windows passed, ten real capture variants at 1440×810 through 3440×1440. My manual screenshot review **failed artistic approval**: imported pixel grass was too uniformly yellow, some road tiles had obvious repetitive stripes, the first foliage crop included unwanted pixels, and the cave floor/wall source mapping became nearly indistinguishable. Following that run, source-tile selection and foliage cropping were corrected; a follow-up cave-floor pass abandons blank/striped atlas regions in favor of textured cold stone.

**Do not represent technical green as release readiness.** Our current cottage/storage/forge remain original modular candidates but visibly less detailed than CC0 environment plants. The hero body/equipment silhouettes and cave room composition still need design review. Art Gate A remains **open**, PR stays **draft** and no major new gameplay systems were implemented in this pack audit.

**Production-size suggestion, not yet canonical:** the 16px ecosystem suggests adding a smaller **16×24** character candidate inside the existing 24×32 cell, rather than prematurely locking 24×32 as full-body size. Review at actual normal play zoom.

### Final asset-audit CI / visual verification

[Follow-up final CI run: 38153596007](https://github.com/Stoffe101/PixelTown/actions/runs/38153596007): **both Linux and Windows succeeded**. Real Godot screenshots include 1920×1080, 2560×1440, 3440×1440, a small 1440×810 window and zoom variants. The selected four Pixel-boy/AAA PNGs were SHA256-verified before use.

**Review result: Art Gate A still NOT PASSED.** Village foliage/terrain has stronger pixel craft than the current simplistic cottages and workshop. Bright grassy fields look repetitive/too yellow, and major paths read as a regular tiled strip rather than organic terrain. Cave floor/wall contrast recovered from the previous blank/misaligned selection, but the encounter space is still too empty and geometric. Current character/helmet silhouettes are functional and aligned but far from an approved warm, expressive PixelTown cast.

**Next art-only actions:** redraw the main cottage, storage and forge in layered Aseprite masters against the selected terrain palette; replace repeating center road/grass fills with coherent edge/corner variants; create a bounded cave chamber with walls, corners, transitions and a more readable encounter centerpiece, preferably testing the 0x72 CC0 material as its own coherent alternate before mixing it. Compare two character silhouettes and equipment during motion. Until that happens, don't lock a production tile/character style and don't merge art as final.

## Visual rejection and composition overhaul, 2026-10-11

The owner explicitly rejected the previous screenshot quality as resembling toy blocks rather than a genuinely beautiful pixel-art village. We should not treat the CC0 packs alone or passing CI as a solution. This pass narrowed/branched roads, switched to a less noisy original 16-variant meadow, isolated recognizable building silhouettes from the pinned CC0 source with transparent crops, reduced debug HUD clutter and removed cave's repetitive brick-floor carpet. A damaged manually committed PNG caused a CI failure, was **deleted**, and replaced by a reproducible source-to-PNG process (`tools/art/curate_v4_houses.py`). Screenshots were reviewed at native Godot capture scale. **The current result remains too sparse and modular-looking to pass Art Gate A.**

CI provenance: [last green art-camera run, before source-driven wood visuals](https://github.com/Stoffe101/PixelTown/actions/runs/38156614365). Any later run/capture supersedes it for code-quality claims. The wood-hauling sprite and plot alignment were adjusted to match the actual conserved resource ledger, preserving all simulation tests.

Full, explicit acceptance/failure criteria in [12_VISUAL_QUALITY_GATE.md](12_VISUAL_QUALITY_GATE.md). The next art work should be a source-editable, **hero-quality blacksmith and character**, not random decorative scatter. The PR stays draft and main unchanged.

## 2026-10-11: composition, grounded wood hauling and QA revision

The owner called out the previous render as resembling toy bricks. Instead of adding random decoration, the branch now separates concerns: pinned CC0 nature art with **reproducibly masked, transparent** candidate facade crops (not damaged hand-uploaded PNGs); quieter original meadow variants and thinner branching paths; a cooler, quieter cave floor rather than a repeating brickwork carpet; and a smaller world-first diagnostic HUD.

Critical actual-scene fixes: fit the cottage, storage, forge and cave gate into the **1920×1080** camera view (where the first house was previously clipped and cave was offscreen), update cave click target, and align the physical construction plot with the worker's simulation target. Three delivered bundles and the one carried bundle are now shown **only when the real demonstration resource ledger says they exist**.

- [CI run 38156344505](https://github.com/Stoffe101/PixelTown/actions/runs/38156344505): successful reproducible source-derived building imagery on Linux and Windows, replacing broken uploaded PNG.
- [CI run 38156614365](https://github.com/Stoffe101/PixelTown/actions/runs/38156614365): passed road and cave floor revision, real captures at 16:9 and ultrawide.
- [CI run 38157195023](https://github.com/Stoffe101/PixelTown/actions/runs/38157195023): passed simulation-linked carried/delivered wood sprites.
- [CI run 38157472174](https://github.com/Stoffe101/PixelTown/actions/runs/38157472174): passed camera/landmark composition and smaller temporary HUD. Real screenshots reviewed at 1920×1080 and 3440×1440.

**Art Gate A: STILL FAILED.** The 1080p framing and material feedback are genuinely better, but the villagers remain crude, the supposedly medieval CC0 facades are too generic and the cave lacks convincing wall geometry, lighting hierarchy and a recognizable adventure composition. The next visual stage must be a **purpose-authored original hero building and human/equipment sheet** in Aseprite, not a sixth automatic background-tile variation. No final art is approved and no main merge is authorized.


## 2026-10-12 reusable scene pilot (awaiting CI and visual sign-off)

Added five original RGBA single-object native-pixel candidate drawings (house, smithy, oak, rock, barrel), one 16px manual painting atlas, seven shared scene prefabs with exposed Inspector settings and authored colliders, a drag-and-drop showcase using multiple shared instances, an Aseprite CLI batch export workflow, and test coverage for texture-resource identity and instance overrides. The existing two layouts, demo movement/combat, markers, current terrain and proprietary/CC0 separation are deliberately unchanged. New showcase capture modes will be in CI artifacts. New art is deliberately labeled **not owner approved**; terrain-bitmask rules, character redesign, richer building hand-polish, Aseprite layered masters for these candidates, physical Windows QA and live Aseprite reimport demonstration remain outstanding.
