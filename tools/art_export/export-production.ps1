$ErrorActionPreference = 'Stop'
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { throw 'Python 3 required' }
& $python.Source (Join-Path $PSScriptRoot 'export_production.py') @args
if ($LASTEXITCODE -ne 0) { throw "Production sprite export failed: $LASTEXITCODE" }
