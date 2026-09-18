# Watches config.json by polling; when it changes, re-syncs prices into ALL
# HTML files (meta description / og:description / twitter:description + JSON-LD).
# Runs in the background: powershell -File watch-prices.ps1
# NOTE: saved as UTF-8 WITH BOM (included library contains Cyrillic).

$siteRoot = $PSScriptRoot
$syncScript = Join-Path $siteRoot 'sync-prices.ps1'
$cfgPath = Join-Path $siteRoot 'config.json'

if (-not (Test-Path $cfgPath)) {
  Write-Output ("config.json not found: " + $cfgPath)
  exit 1
}

$lastWrite = (Get-Item $cfgPath).LastWriteTimeUtc
Write-Output ("[watch] watching " + $cfgPath)

# Initial sync on startup
try {
  $out = & $syncScript
  Write-Output ("[watch] initial sync: files changed " + ($out | Select-String 'Files changed'))
} catch {
  Write-Output ("[watch] initial sync error: " + $_)
}

while ($true) {
  Start-Sleep -Seconds 2
  try {
    $w = (Get-Item $cfgPath).LastWriteTimeUtc
    if ($w -ne $lastWrite) {
      $lastWrite = $w
      Start-Sleep -Milliseconds 400   # debounce: editors fire several writes per save
      $out = & $syncScript
      Write-Output ("[watch] config.json changed -> " + ($out | Select-String 'Files changed') + " at " + (Get-Date -Format 'HH:mm:ss'))
    }
  } catch {
    Write-Output ("[watch] error: " + $_)
  }
}
