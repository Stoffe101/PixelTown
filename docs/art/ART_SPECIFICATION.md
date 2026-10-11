# PixelTown art specification (DRAFT, 2026-10-12)
- Target original, legible medium-detail pixel art; Necesse readability, Stardew warmth, subdued Graveyard Keeper workshop/cave atmosphere, no copied assets.
- 16x16 orthographic square world grid; four-direction gameplay. 24x32 animation **cells** are a provisional test, not approved full-body dimensions.
- Draw at native pixel resolution, hard edges, cluster-level shade ramps (usually 3–5 colors/material), northwest highlights, deliberate dark outline without pure black everywhere.
- Buildings read by silhouette and profession from regular gameplay zoom; foot origin at ground and window/door height coherent with inhabitants.
- Ground tiles should vary sparingly, avoid repetitive noise, and gain **real** corner/shore/road connectivity before being labeled production autotiles.
- Village saturation restrained; dungeon dark/cool but units, loot and hazards retain value contrast. No illustrations downscaled to fake pixels.
- Review new artwork at 1920x1080, 2560x1440, 3440x1440 in actual Godot scene before style sign-off.
- Proprietary PixelTown original files remain ARR; third-party provenance and license review is mandatory for imports. New native sample PNGs are review candidates, not sign-off.
