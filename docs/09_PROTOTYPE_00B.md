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
