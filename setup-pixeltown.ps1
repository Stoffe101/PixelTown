param()
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Push-Location $PSScriptRoot
try {
    Write-Host "PixelTown: checking the real, committed art assets..." -ForegroundColor Cyan
    $required = @(
        'assets/terrain.png',
        'assets/objects.png',
        'assets/characters.png',
        'assets/equipment.png',
        'assets/atlas.json',
        'assets/original/hero/smithy.png',
        'assets/original/hero/cottage.png',
        'assets/original/hero/storehouse.png',
        'assets/original/hero/cave_gate.png',
        'assets/original/hero/mature_tree.png',
        'assets/original/hero/inhabitants.png',
        'assets/original/hero/guard_equipment.png',
        'assets/original/hero/construction_site.png',
        'assets/original/hero/watch_hut.png',
        'assets/original/hero/ancient_altar.png',
        'assets/third_party/ninja_adventure/tileset_floor.png',
        'assets/third_party/ninja_adventure/tileset_interior_floor.png',
        'assets/terrain_paint_tileset.tres'
    )
    $missing = @($required | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -ne 0) {
        Write-Host "Missing committed assets:" -ForegroundColor Red
        $missing | ForEach-Object { Write-Host "  $_" }
        throw "Fetch and pull the latest feature branch; do NOT generate art to fix a broken checkout."
    }
    Write-Host "Success: all required assets are present on disk." -ForegroundColor Green
    Write-Host "Open project.godot in Godot and edit scenes/levels/village_layout.tscn."
    Write-Host "Generated/source authoring tools are optional; opening the game does not depend on them."
} finally {
    Pop-Location
}
