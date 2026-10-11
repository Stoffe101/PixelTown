# Ninja Adventure selected environment textures (CC0)

These four specific original PNG textures are generated into this folder by `tools/art/import_ninja_cc0.py` from the author's pinned official Godot 4 example project. They are not copies of an arbitrary full asset pack.

**Author:** Pixel-boy + AAA
**Original asset-pack page:** https://pixel-boy.itch.io/ninja-adventure-asset-pack
**Upstream source:** https://github.com/pixel-boy/NinjaAdventure
**Pinned source commit:** `6ac78232d5aedcc85ce5f27d060ea92366f7c24a`
**Artwork license:** CC0 1.0 Universal. Commercial use, modification, distribution and public repo storage of CC0 artwork permitted. Credits appreciated, not required. Original project **code is not used** and its license is not assumed from these artwork rights.

Only selected exterior terrain, abandoned-village nature/rock textures, interior floor and stone walls are imported. SHA256 for each is specified in the importer and emitted to the provenance JSON for reproducibility.

Locally, from your copy of the **Godot Project V4.zip** supplied in the pack:

```bash
python tools/art/import_ninja_cc0.py --zip "/path/to/Godot Project V4.zip"
```

Alternatively, use the official GitHub repo checked out to the pinned commit:

```bash
python tools/art/import_ninja_cc0.py --source /path/to/NinjaAdventure
```

Godot will then see the selected PNGs. In CI they are imported from a separate pinned read-only checkout.

**Do not confuse this selection with our original proprietary PixelTown art.** The third-party source files are not automatically covered by PixelTown's All Rights Reserved notice. This is a visual experiment, not the accepted final style. The import path deliberately excludes Ninjas and other action-game characters.
