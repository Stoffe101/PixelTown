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

## Subsequent real-engine findings

**First original-layered-art capture:** [run 38159824141](https://github.com/Stoffe101/PixelTown/actions/runs/38159824141), green on Linux and Windows. Original distinct smithy, cottage, storehouse, cave gate, mature trees and cliff modules visibly eliminate the previous collage of arbitrary unrelated atlas slices. **They are still a hand-polish starting point, not approved commercial art.** Even improved buildings sit in a sparse grass/road clearing, and the first chamber wall repeated too obviously.

**Character pass:** original guard/villager 4-direction frames and matching separate helmet/shield/sword overlays were added, plus automatically verified editable sources. The completed hero-art generator and validation passed [CI run 38160328776](https://github.com/Stoffe101/PixelTown/actions/runs/38160328776). Their faces, poses and animations remain candidate quality; being nonempty and correctly anchored is not artistic approval.

**Pixel-density evidence:** see [14_DISPLAY_DENSITY_EXPERIMENT.md](14_DISPLAY_DENSITY_EXPERIMENT.md). The 2×-physical-pixel 1080p capture looks less toy-like, but a universal 2× ultrawide capture leaves acres of empty meadow. No final display-scale rule selected.

**Latest visual-specific work:** a purpose-authored half-built scaffold and a completed community hut replace the earlier X-marked crossed-square placeholder; three real delivered wood bundles remain tied to the demo's material ledger. A cave mineral shrine adds a deliberate focal landmark. These are isolated original PNGs with layered editable masters. Review them only using CI evidence from commits after this paragraph; don't claim the latest revisions look finished before inspecting those images.

**Art Gate A remains open.** Next artistic problem is environmental composition and character charm, not additional code-generated roof styles.

## Real visual QA outcome for the complete first pass

[CI run 38161167674](https://github.com/Stoffe101/PixelTown/actions/runs/38161167674) passed **Linux and Windows**, including deterministic simulation tests, actual Godot 1920×1080 / 2560×1440 / 3440×1440 village-and-cave screenshots, density comparisons, source-layer verification, and frame/PNG integrity. The exact tested artwork includes the two-stage hut and mineral shrine.

**Actual manual screenshot review:**
- The original pitched buildings now have separate silhouettes and coherent material sets. The arbitrary ruined-building atlas crops and overflowing neighboring pixels are gone from the four key landmarks.
- The supported wood-hauling demonstration now shows discrete delivered logs, scaffolding and a matched finished structure; it is no longer a giant X-marked square.
- The guard visibly equips a layered helmet/shield/sword, but the character animation is still **blocky and too simple** compared to the target professional visual language. Correct sheet geometry alone is not attractive art.
- The cave has a threshold, authored rock forms and central mineral shrine; despite that, terrain remains too uniform and the cave wall/lighting composition is still **not immersive**.
- The 1920×1080 2× density sample looks less like oversized toy blocks, while the 3440×1440 universal 2× view reveals too much empty meadow. No scale is final.

**Conclusion: Art Gate A remains FAILED.** This is a genuine, technically green, source-editable starting point but **not a release-worthy art direction yet**. The next art pass should prioritize hand-drawn source-art improvements, natural landscape and cave transitions, lighting/value grouping, and fluid expressive animations, evaluated at both screen sizes. Keep PR #4 draft and `main` untouched.

## Artist handoff: persistent Godot layouts and warning cleanup

The follow-up handoff (draft PR #4) replaces runtime-only hard-coded prop positions with the real, editor-editable `scenes/levels/village_layout.tscn` and `cave_layout.tscn`, 21 individual drag-in prop prefabs, a paintable `TileMapLayer` overlay, a colored editor-only placement backdrop, and explicit Marker2D positions used by the worker, construction plot, entrance and combat actors. The deterministic simulation and screenshot runner read the same markers. Deleted the unused rectangle-painted `art/world_canvas.gd` that emitted GDScript integer-division and unused-parameter warnings; fixed the remaining display test divisions. `.gitattributes` now pins Godot/script resources to LF on all platforms, while `.gitignore` hides generated Godot script UID/cache files and regenerated preview artwork. Manual artwork belongs in `assets/handmade/` and `art/handmade/` (never ignored). See [Godot editor artist guide](15_GODOT_EDITOR_ARTIST_GUIDE.md).

## Real asset/scene migration (October 2026)

A clean checkout had previously been unable to open the levels because generated PNGs were excluded by `.gitignore`. This was a packaging and architecture defect. It has now been fixed on the draft branch: all required original PNGs, 11 layered OpenRaster masters, approved-for-redistribution CC0 sprite sheets/provenance and the actual painted terrain TileMapLayers have been committed to Git. The runtime `world_art.gd` no longer constructs terrain. Building completion switches visibility of two **scene-owned** sprites rather than constructing/selecting textures in code. The temporary asset-publishing workflow was deleted after its successful one-time commit; normal CI is strictly read-only and checks the **committed content**. This migration is technical and does not imply visual art approval.
