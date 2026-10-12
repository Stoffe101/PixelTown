# PixelTown production art mapping

This branch now uses art/production_assets.json to bind each future **real** layered Aseprite source to the PNG already referenced by a draggable .tscn scene. Missing handmade masters are explicitly marked, not fabricated or mislabeled as complete.

For an oak-tree update: open assets/sprites/environment/oak_tree.png as a scale/layout reference. Redraw in Aseprite with genuine layered pixels and save as art/handmade/environment/oak_tree.aseprite. Run in PowerShell from the repository root:

    powershell -ExecutionPolicy Bypass -File .\\tools\\art_export\\export-production.ps1 --id oak_tree

This verifies the sprite dimensions (oak is currently 80x96) before writing to the actual assets/sprites/environment/oak_tree.png referenced by scenes/environment/OakTree.tscn. All placed instances inherit the new texture, keeping world coordinates. Use --dry-run to preview the map and omit --id for all existing real masters.

The old export-all.ps1 targets unmapped experiments only. The new export-production.ps1 is canonical for permanent Godot prefabs. CI checks mapping uniqueness, alpha, texture links and dimensions with python tools/art_export/validate_production_manifest.py. This is a technical pipeline, NOT visual approval, and should not be confused with hand-authored artwork.
