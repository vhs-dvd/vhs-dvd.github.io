# Syncs prices from config.json into the HTML files on disk
# (meta description / og:description / twitter:description + JSON-LD "price").
# Run once after changing config.json, before uploading to hosting.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File sync-prices.ps1
# NOTE: saved as UTF-8 WITH BOM (contains Cyrillic).

$ErrorActionPreference = 'Stop'
$siteRoot = $PSScriptRoot
. (Join-Path $siteRoot 'includes\prices.ps1')

$pages = @(Get-ChildItem -Path $siteRoot -Filter *.html -File | Select-Object -ExpandProperty FullName)
$sub = Join-Path $siteRoot 'otsyfrovka-video-kyiv'
if (Test-Path $sub) {
  $pages += @(Get-ChildItem -Path $sub -Filter *.html -File | Select-Object -ExpandProperty FullName)
}

$changed = 0
foreach ($page in $pages) {
  $original = [System.IO.File]::ReadAllText($page, [System.Text.Encoding]::UTF8)
  $updated  = Update-PagePrices -Html $original -Root $siteRoot
  if ($updated -ne $original) {
    [System.IO.File]::WriteAllText($page, $updated, (New-Object System.Text.UTF8Encoding $false))
    Write-Output ("updated: " + (Split-Path -Leaf $page))
    $changed++
  } else {
    Write-Output ("unchanged: " + (Split-Path -Leaf $page))
  }
}
Write-Output "Done. Files changed: $changed"
