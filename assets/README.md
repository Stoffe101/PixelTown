# PixelTown original art masters: Prototype 00B

**Status:** Art Direction v1.0 selected; individual sprites and screenshots await owner review. No approved production baseline yet.

These are actual **RGBA PNG tilesets and sprite sheets** generated deterministically from an editable, original Python pixel-art master, `tools/art/build_art.py`. No game asset is copied from Necesse, Graveyard Keeper or Stardew Valley, and no third-party art pack is included.

Run from the repository root:

```bash
python tools/art/build_art.py
python tools/art/validate_assets.py
```

This writes the PNG files and `atlas.json` to this directory. Python standard library only. **Before opening the Godot project locally, run the generator once.** Linux and Windows CI perform this step automatically. The generated PNGs are intentionally not committed at this stage because the master artwork is under owner review; the images are also attached as CI artifacts for examination. Exported PNGs are editable in LibreSprite, Aseprite, Krita and other pixel editors, but changes to the generated files should be reflected in the master source before regeneration.

## Sprite layout

| File | Sheet size | Layout |
| --- | --- | --- |
| terrain.png | 256×64 | 16×16 tiles, 16 columns and four rows (grass, path/water, cave floors and walls) |
| objects.png | 512×256 | Individual building/prop sprites; see `atlas.json` for exact pixel bounds |
| characters.png | 384×256 | 24×32 cells, 16 columns × 8 rows, 8 frame slots for each size |
| equipment.png | 384×128 | Overlays matching guard cell coordinates and foot anchors |

Rows 0–3 of character sheet are villager directions south/north/west/east; rows 4–7 are guard directions. Columns 0–7 contain the smaller **20×30** design centered in a 24×32 cell; columns 8–15 contain the **24×32** design. Within each eight-column group: four idle/walk frames, two work frames, two attack frames. Equipment overlays occupy identical 24×32 coordinates and are animated with the same frame index.

Godot texture filtering is nearest-neighbor; characters and equipment share the same pixel anchor `(-12, -31)`. Buildings use a foot-origin y-sorted anchor, and terrain is rendered through `TileMapLayer`.

Review normal-scale Godot captures before choosing the permanent sprite size. Master generator scripts are for **asset authoring**, not frame-by-frame gameplay rendering. No game runtime uses the old code-drawn scene art.

## License and sources

All source art made for this pass is original to PixelTown and subject to the repository's All Rights Reserved LICENSE. Third-party art dependencies: **none**. General readability, atmosphere and character warmth were studied in official press/reference material only. Those copyrighted reference images are **not included in this repository**.
