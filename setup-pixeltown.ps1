param(
    [string]$GodotExampleZip = ""
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Push-Location $PSScriptRoot
try {
    Write-Host "PixelTown artist setup (draft branch)" -ForegroundColor Cyan
    $python = Get-Command py -ErrorAction SilentlyContinue
    if ($null -ne $python) { $exe = "py" } else { $exe = "python" }
    & $exe --version
    if ($LASTEXITCODE -ne 0) { throw "Python 3 is required. Install it from python.org and rerun." }
    & $exe -m pip install --disable-pip-version-check "pillow==11.3.0"
    if ($LASTEXITCODE -ne 0) { throw "Could not install Pillow for original asset exports." }
    & $exe tools/art/build_art.py
    if ($LASTEXITCODE -ne 0) { throw "Original terrain generation failed." }
    & $exe tools/art/validate_assets.py
    if ($LASTEXITCODE -ne 0) { throw "Original atlas validation failed." }
    & $exe tools/art/hero_art.py
    if ($LASTEXITCODE -ne 0) { throw "Hero sprite generation failed." }
    & $exe tools/art/validate_hero.py
    if ($LASTEXITCODE -ne 0) { throw "Hero sprite validation failed." }
    $cc0 = "assets/third_party/ninja_adventure/tileset_floor.png"
    if (-not (Test-Path $cc0)) {
        if (-not $GodotExampleZip) {
            Write-Host "Your licensed CC0 environment subset is not installed." -ForegroundColor Yellow
            $GodotExampleZip = Read-Host 'Full path to your "Godot Project V4.zip" (from the attached packs)'
        }
        $GodotExampleZip = $GodotExampleZip.Trim('"')
        if (-not (Test-Path $GodotExampleZip)) {
            throw "Could not find the source ZIP. No downloaded third-party art is copied without its license/provenance."
        }
        & $exe tools/art/import_ninja_cc0.py --zip $GodotExampleZip
        if ($LASTEXITCODE -ne 0) { throw "CC0 import or hash verification failed." }
    }
    & $exe tools/art/curate_v4_houses.py
    if ($LASTEXITCODE -ne 0) { throw "Legacy CC0 compatibility export failed." }
    Write-Host ""
    Write-Host "Ready. Open project.godot in Godot 4.7.2." -ForegroundColor Green
    Write-Host "Then open scenes/levels/village_layout.tscn or cave_layout.tscn to position objects."
    Write-Host "Generated files are preview exports. Save any hand-drawn replacements under assets/handmade/."
    Write-Host "Never edit the source ZIP or commit a no-redistribution pack."
} finally {
    Pop-Location
}
