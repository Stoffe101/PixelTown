# Art Pass 01: an original PixelTown visual foundation

**Started 2026-10-11. Status:** working visual-review pass on draft [PR #4](https://github.com/Stoffe101/PixelTown/pull/4). No final art sign-off and no merge to `main`.

## Why this pass replaces the old approach

The repeated attempts to make the earlier rectangle-painted objects and arbitrarily cropped abandoned-village atlas pieces look polished did not succeed. The village looked like individual building blocks placed on a background, and an overly repeated cave cliff layer looked like wall wallpaper. Technical green CI did not validate visual cohesion.

Instead, the exact central production objects are now **purpose-authored as PixelTown-original artwork**, each with an isolated transparent PNG and a layered OpenRaster master. The artwork is generated from editable, reproducible source `tools/art/hero_art.py`. This is a substantially different production structure from runtime rectangle painting or borrowing a random atlas subsection.

## Hero objects delivered as original art

- **164×126 smithy** with a pitched weathered slate roof, layered timber frame, stone plinth, chimney, forge opening, anvil, workbench, active-looking materials, coherent colored outline and a left-lit material palette. A forge is identifiable independently of a label.
- **138×113 cottage** with warm clay roof, entrance, warm-glazed window, plaster/timber and planting.
- **124×108 storehouse** with recessed wide cargo doors, crates and storage identity.
- **130×110 cave entrance** with layered stone, an actual recessed dark opening, moss, threshold and lantern markers.
- **86×112 mature tree**, isolated source (no tree-trunk/neighbor-asset leakage).
- **150×106 cave cliff** supporting a coherent upper-chamber boundary, rather than repeating a single tile.
- **384×256 original inhabitant/guard sprite sheet**, 4 directional rows per role and 8 frames each of two aligned size candidates. **384×128 matching equipment overlay** for guard helm/armor/shield/sword. Illustrations and frame timing are subject to further visual critique.

Each generated sprite PNG is under `assets/original/hero/`, and every editable layered source is under `art/source/architecture/*.ora`. The ZIP-based OpenRaster master contains editable named RGBA layers; it can be opened by layered-art software such as Krita and converted/saved into a native Aseprite working file before hand polish. **These are layered raster sources, not claimed to be native .aseprite files.** The painter/export source is original Python + Pillow, not source-lifted copyrighted art.

Old CC0 Ninja terrain remains credited and SHA-pinned. CC0 abandoned-village facades are no longer the centerpieces; scripts remain only as recorded comparison/art-provenance history. No restricted/non-commercial art was introduced.

## Verification and gate

Before running Godot, CI generates original PNGs and layered masters on **both Windows and Linux**, validates image dimensions, nonempty character frames, layered-source integrity, export/master pixel matching and provenance separation. The existing deterministic conserved-wood, background cave activity, import/parse, engine-startup and real screenshot checks remain.

Real captures continue to cover **1920×1080, 2560×1440, 3440×1440** plus 1440×810 and 2× camera zoom. Compare at actual game zoom: do the buildings now look like a single village, does the guard belong there, is the cave believable, are trees and rocks visibly isolated rather than slices of a large atlas?

**Work still required, not falsely considered complete:** fine Aseprite hand polish for face/clothing/personality; proper path/shore autotiles, nonrepetitive terrain; cave-room structure and light hierarchy; real directional motion feel; collision/pathing; master source editability in Aseprite; visual sign-off on actual Windows 3440×1440 monitor. Full blueprint placement and expedition progression are deferred.

Art Gate A must fail if any of those visual fundamentals still look cheap. Do not merge PR #4 until the owner specifically approves actual gameplay-resolution captures.
