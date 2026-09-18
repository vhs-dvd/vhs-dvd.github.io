# Server-side price injection for vhs-dvd.org.ua
# Replaces static prices in HTML (meta descriptions, JSON-LD "price") with
# actual values from config.json. Used by serve.ps1 (per request) and
# sync-prices.ps1 (writes changes back to the HTML files on disk).
#
# NOTE: this file contains Cyrillic literals -> must be saved as UTF-8 WITH BOM.

function Get-PricingRows {
  param([string]$Root)
  $cfgPath = Join-Path $Root 'config.json'
  $cfg = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
  return @($cfg.pricing)
}

function Update-PagePrices {
  param([string]$Html, [string]$Root)

  try { $rows = Get-PricingRows -Root $Root } catch { return $Html }
  if (-not $rows -or $rows.Count -eq 0) { return $Html }

  # Page format from <body data-format="...">
  $fmt = $null
  if ($Html -match '<body[^>]*data-format="([^"]+)"') { $fmt = $Matches[1] }

  $fmtReMap = @{
    vhs      = 'vhs'
    hi8      = 'hi8|video8|digital8'
    minidv   = 'minidv'
    audio    = 'аудіо касети'
    bobina   = 'бобін'
    betacam  = 'betacam'
    minidisc = 'minidisc'
    photo    = 'сканування|фото'
  }

  $own = $null
  if ($fmt -and $fmtReMap.ContainsKey($fmt)) {
    $re = $fmtReMap[$fmt]
    foreach ($r in $rows) { if ($r.format -match $re) { $own = $r; break } }
  }

  $vhsRow = $null; $photoRow = $null
  foreach ($r in $rows) {
    if (-not $vhsRow   -and $r.format -match 'vhs')             { $vhsRow = $r }
    if (-not $photoRow -and $r.format -match 'сканування|фото') { $photoRow = $r }
  }
  if (-not $vhsRow) { $vhsRow = $rows[0] }

  # Price for a given unit: own-format row first, then photo row (for frames), else VHS price
  $priceFor = {
    param($unit)
    if ($own -and $own.unit -and $own.unit.Contains($unit)) { return [string]$own.price }
    if ($unit -eq 'кадр') {
      if ($photoRow) { return [string]$photoRow.price } else { return $null }
    }
    if ($vhsRow) { return [string]$vhsRow.price } else { return '240' }
  }

  # 1) "240 ₴/год", "240 грн/кадр" etc. (in meta description/og/twitter)
  $pattern = '(\d[\d\s]*)\s*(₴|грн)\s*/\s*(год|кадр)'
  $html = [regex]::Replace($Html, $pattern, {
    param($m)
    $p = & $priceFor $m.Groups[3].Value
    if ($p) { return $p + ' ' + $m.Groups[2].Value + '/' + $m.Groups[3].Value }
    return $m.Value
  })

  # 2) JSON-LD structured data: "price": "240"
  $ownPrice = $null
  if ($own) { $ownPrice = [string]$own.price } elseif ($vhsRow) { $ownPrice = [string]$vhsRow.price }
  if ($ownPrice) {
    $html = [regex]::Replace($Html, '("price"\s*:\s*")(\d+)(")', {
      param($m)
      return $m.Groups[1].Value + $ownPrice + $m.Groups[3].Value
    })
  }

  return $html
}
