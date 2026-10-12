# PixelTown pixel-density visual comparison

**2026-10-11.** These are actual Godot capture results from [CI run 38160772483](https://github.com/Stoffe101/PixelTown/actions/runs/38160772483), not resized concept illustrations. This evaluates art pixel density, not the game's final native-resolution API.

## Tested layouts

- Existing project: base 640×360, integer viewport stretch/expand. At 1920×1080 the usual 3× physical scaling shows 16 logical px terrain at 48 physical pixels. At 3440×1440 the current CI render uses a larger scale and expanded horizontal viewport.
- Candidate art density: 1920×1080 with logical 960×540 at **2×**, and 3440×1440 with logical 1720×720 at **2×**. CI changes the project file **temporarily in a throwaway environment**, captures both environments, restores the original project and uploads comparison PNGs.
- Both scene modes and both resolutions passed pixel-dimension/log checks on Linux; Windows remained green. A first trial using a 960×540 base for *both* monitors unexpectedly yielded 1290×540 for ultrawide. The experimental renderer now explicitly sets each comparison canvas to half its target physical dimensions so one logical pixel is always two physical pixels.

## Artistic reading of the screenshots

**1920×1080:** 2× shows more village and far less magnified, toy-block pixels than the previous 3× capture. Buildings read more appropriately relative to the terrain; the path, garden, trees, water and bridge appear in one frame. **The 2× density deserves continued evaluation**. Its broader composition also exposes remaining grassy emptiness and lack of natural shore/path transitions.

**3440×1440:** a universal 2× setup shows *too much empty meadow and water* around a small central village. This is **not acceptable as the finished ultrawide composition**. Improving the sprite size alone does not solve ultrawide framing; future art passes need intentional forest/outskirts composition and/or an independently tested ultrawide camera-framing choice. A 1.5× camera zoom layered on a true 2× pixel canvas is a *possible* test, not an approved setting. Avoid fractional source-pixel shimmer, blur or lost world interaction coordinates.

**Cave:** the 2× experiment similarly emphasizes the need for a properly constructed chamber. Source-authored cliff modules, entrance and altar have been started, but the background still requires recognizable architecture and value/lighting design.

## Decision status

The canonical `project.godot` remains at **640×360 integer/expand** while art is under review. **Do not silently change the game's live pixel-density contract based on a single trial.** Keep both screenshot variants and test any future choice on real Windows hardware at 1920×1080 and **3440×1440**, with visible movement/camera pan and no flickering pixels.

Additional art must be judged at its actual normal gameplay zoom, not only a large isolated sprite preview. These images are available in the pipeline's `linux-godot-evidence` artifact.
