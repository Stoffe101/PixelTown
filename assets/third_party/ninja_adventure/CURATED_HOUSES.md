# Derived, unapproved CC0 village facade assets

The file `curated_houses.png` is generated reproducibly by `tools/art/curate_v4_houses.py` from Pixel-boy and AAA's **Ninja Adventure** official Godot V4 example atlas (`tileset_village_abandoned.png`).

**License:** CC0 1.0 (commercial use, adaptation and public redistribution permitted). Source and pinned upstream commit are recorded in `README.md` and `PROVENANCE.json` in this directory. **This is third-party CC0 artwork, not proprietary original PixelTown art.**

Three individual 16px-density architecture samples share one 240×96 sprite sheet: cottage (0,0,65×81), storage (80,12,51×48) and smithy shell (160,0,65×75). Their crop polygons remove neighboring tiles without leaving opaque atlas backgrounds. The source file and script are editable; output PNGs are not committed because they are always built from the pinned verified input.

Run after `python tools/art/import_ninja_cc0.py --zip "/path/to/Godot Project V4.zip"`:

```bash
python -m pip install pillow==11.3.0
python tools/art/curate_v4_houses.py
```

These facades are **temporary layout assets** used to test the environment's density and proportions. A proper Aseprite source library and distinct functional details are still required before Art Gate A can be marked approved.
