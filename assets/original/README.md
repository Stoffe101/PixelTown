# Original PixelTown hero artwork

The `hero_art.py` source in `tools/art/` generates eight original pixel-art sprites and their **layered editable OpenRaster (.ora)** masters. PNGs live here and the layered sources live at `art/source/architecture/`.

Run:

```sh
python -m pip install pillow==11.3.0
python tools/art/hero_art.py
python tools/art/validate_hero.py
```

The generated PNGs and .ora are included in CI artifacts on the draft PR, rather than committed as an opaque dependency or mistaken for finalized art. Original PixelTown source is All Rights Reserved. Third-party CC0 nature/terrain assets remain separately inventoried in `assets/third_party/`. The original art direction is being evaluated, not accepted yet.

For Aseprite work, open/export individual PNG frames, or use Krita to open the layered .ora and save per-layer PNGs into Aseprite. Save the artist's actual working master as a native .aseprite file once editing starts. The current .ora source must not be misrepresented as an existing native Aseprite master.
