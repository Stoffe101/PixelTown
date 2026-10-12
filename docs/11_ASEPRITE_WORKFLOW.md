# PixelTown Aseprite pipeline: artist handoff v1

**Status:** initial working practice for Prototype 00B. Subject to the user's visual sign-off. PixelTown remains proprietary ARR; third-party CC0 artwork stays separately attributed.

## 1. Master pixels and scale

- **World placement grid:** square **16×16** logical-pixel cells (not isometric). Art may overhang multiple cells but collision/door/footprint coordinates remain on the 16px grid.
- **Base animation cell:** **24×32** for the current PixelTown trial; draw at least **two versions** within that cell: nominal **20×30** and smaller **16×24**, keeping bottom-foot anchored at `(12,31)`. Do not scale nearest-neighbor resizes to fake a new sprite resolution; draw silhouettes to size.
- **Four directions:** South, North, West, East. For animated units, retain the same bottom-foot pivot in every frame. Aseprite animation tags: `idle` 2, `walk` 4, `carry` 2–4, `work` 2–4, `attack` 2–4, `hit` 1–2.
- **Equipment:** helmet, hair, torso armor, shield, weapon, held object as named optional layers with identical pixel-frame alignment. Assign equipment-behind or equipment-in-front depending on direction (e.g. sword shouldn't be behind the body in every direction).
- **Native source fidelity:** if referencing selected CC0 Ninja Adventure, study its 16×16 units, cluster shapes and highlight ramps. Never simply enlarge, pixel-trace or recolor an upstream character and call it an original PixelTown sprite. Use a new base template authored here.

## 2. Aseprite file and layer structure

```text
art/source/
  palette/PixelTown_study_v1.gpl
  villagers/base-villager.aseprite
  villagers/base-guard.aseprite
  equipment/helmet-01.aseprite
  equipment/shield-01.aseprite
  equipment/sword-01.aseprite
  architecture/medieval-modules.aseprite
  architecture/cottage-01.aseprite
  architecture/storage-01.aseprite
  architecture/smithy-01.aseprite
  terrain/grass-path-shore.aseprite
  cave/cave-stone-moss.aseprite
  creatures/first-cave-enemy.aseprite
art/export/                        # generated deterministic non-trimmed PNG
```

New base-character layer stack (bottom to top): `shadow`, `equipment_back`, `legs`, `body`, `skin`, `clothing`, `face`, `hair`, `equipment_front`, `held_resource`. **Do not flatten the masters**. Keep animation durations in Aseprite and preserve exactly the same frame timeline for alternative gear layers.

**First practical task for a contributing artist:** open `assets/characters.png` and `assets/equipment.png` after running `python tools/art/build_art.py`. Use those as *layout references*, not as final character designs. Create a new `base-villager.aseprite` with south-facing idle + four walk frames, export as transparent non-trimmed 24×32 frames, and verify a helmet overlay using the same frame coordinates in Godot. Once stable, draw remaining directions and the guard.

## 3. Palette and material rules

`art/palettes/PixelTown_study_v1.gpl` is a **small draft palette study** used to keep original work internally consistent. It is not a recreation of a proprietary pack's exact palette. Use color families for moss foliage, warm timber/plaster, copper roof, dark slate and amber fire; if an upstream CC0 tile is used beside our original sprite, match **value contrast and cluster density**, not only hue.

Per surface, target 3–5 closely related values: colored dark 1px outline, deep shaded surface, broad local midtone, focused warm/cool highlight, optional accent. Avoid heavy pure-black lines on light terrain, fully shaded gradient pixels, and decoration on every cell. Consistent light direction: upper-left; contact shadow below people and buildings.

**Outdoor:** moderate yellow/green variation, rounded vegetation, discrete soil edges, roofing material readable at gameplay zoom. **Cave:** darker cool stone and clear warm torch accents, but leave units and item pickups legible even when lighting is disabled. Keep path/shore corners in a 3×3 minimum autotile family before drawing dozens of random variations.

## 4. Building production recipe

A reusable medieval structure consists of: grid-based foundation, front wall material, roof type + ridge/eaves, anchored doorway, chimney/window set, profession-specific prop set, and optional emissive/light overlay. Keep `floor_footprint` separate from taller visuals. Use bottom-foot anchor and y-sort; overhangs should not change the interactive/obstacle footprint.

Build **one cottage**, **one storage hut**, **one smithy** first. For the smithy, production identity requires an actual furnace glow, anvil/tool rack, coal/metal materials, and worker active pose that occurs only during a real crafting task. Don't make background smoke signal production when no order exists.

## 5. Export and Godot checklist

1. Source file stays layered `.aseprite`, with semantic tags, meaningful frame duration, and a saved palette.
2. Export transparent 1:1 pixels, **no trimming**, no resizing and no resampling. Each 24×32 character frame retains foot `(12,31)` and a separate optional gear frame with identical coordinates.
3. Use deterministic filenames such as `villager_base_south_walk.png`, `guard_helmet_iron_south_walk.png`, `cottage_wood_red_01.png`. Store texture sheet metadata and exact author/source/rights in the provenance inventory.
4. Godot `TileMapLayer`: 16×16 region size, correct grass/road/corner autotiles; use `Sprite2D` or `AnimatedSprite2D` with nearest-neighbor filtering for inhabitants and props. `y_sort_enabled` and footprint-based pivot apply to world objects.
5. Validate identical sheet dimensions/frame counts and nonempty overlays; CI should regenerate camera evidence at **1920×1080, 2560×1440, 3440×1440** and a second zoom.
6. Visual review compares normal-zoom results against **Art Direction v1.0** before locking character dimensions or approved PNG baseline updates.

## 6. Source rights

Original created .aseprite masters and corresponding art: PixelTown's own ARR license. Upstream Ninja Adventure (Pixel-boy + AAA), 0x72 DungeonTileset II and Ansimuz free Tiny RPG assets: respective CC0 rights, separately recorded. Tiny Swords current Free, Cainos, and noncommercial Sprout Lands Basic have **not** been integrated or copied into the public repository.

The simple procedural PNG generator is temporary production scaffolding. Once humans start drawing masters, the authoritative originals should be layered art-source files and their exported sprite sheets, **not** thousands of runtime rectangles or randomly assembled packs.
