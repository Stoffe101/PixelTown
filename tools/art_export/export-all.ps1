$ErrorActionPreference = 'Stop'
$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) { throw 'Python 3 is required for Aseprite export' }
& $Python.Source (Join-Path $PSScriptRoot 'export_aseprite.py') @args
if ($LASTEXITCODE -ne 0) { throw "Aseprite export failed (code $LASTEXITCODE)" }
