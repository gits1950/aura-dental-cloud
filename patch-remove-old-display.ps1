# ============================================================
# Aura Dental - Remove duplicate old renderDisplayScreen
# ============================================================

$filePath = ".\public\index.html"
if (-not (Test-Path $filePath)) { Write-Host "ERROR: file not found" -ForegroundColor Red; exit }

$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# Count how many renderDisplayScreen functions exist
$count = ([regex]::Matches($content, "function renderDisplayScreen\(\)")).Count
Write-Host "Found $count renderDisplayScreen definition(s)" -ForegroundColor Yellow

# Find the OLD one - identified by unique content 'const occupiedChairs'
$oldSig   = "// ========== DISPLAY SCREEN ==========" + "`n" + "function renderDisplayScreen() {"
$oldSig2  = "// ========== DISPLAY SCREEN ==========" + "`r`n" + "function renderDisplayScreen() {"
$altSig   = "function renderDisplayScreen() {" + "`n" + "  const occupiedChairs"
$altSig2  = "function renderDisplayScreen() {" + "`r`n" + "  const occupiedChairs"

$oldStart = $content.IndexOf($oldSig)
if ($oldStart -eq -1) { $oldStart = $content.IndexOf($oldSig2) }
if ($oldStart -eq -1) { $oldStart = $content.IndexOf($altSig) }
if ($oldStart -eq -1) { $oldStart = $content.IndexOf($altSig2) }

if ($oldStart -eq -1) {
    Write-Host "Old function not found - may already be removed" -ForegroundColor Green
    # Check if new one works
    if ((Select-String -Path $filePath -Pattern "WAITING QUEUE") -ne $null) {
        Write-Host "New display screen is present. No action needed." -ForegroundColor Green
    }
    exit
}

Write-Host "Found old function at char $oldStart" -ForegroundColor Yellow

# Find end of old function - next function definition after it
$endMarker1 = "`nfunction approveBooking("
$endMarker2 = "`r`nfunction approveBooking("
$oldEnd = $content.IndexOf($endMarker1, $oldStart)
if ($oldEnd -eq -1) { $oldEnd = $content.IndexOf($endMarker2, $oldStart) }

if ($oldEnd -eq -1) {
    Write-Host "ERROR: Cannot find end of old function" -ForegroundColor Red
    exit
}

Write-Host "Old function ends at char $oldEnd" -ForegroundColor Yellow
Write-Host "Removing old function ($($oldEnd - $oldStart) chars)..." -ForegroundColor Cyan

# Remove the old function block entirely
$newContent = $content.Substring(0, $oldStart) + $content.Substring($oldEnd)
[System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)

# Verify
$countAfter = ([regex]::Matches($newContent, "function renderDisplayScreen\(\)")).Count
Write-Host "renderDisplayScreen definitions after patch: $countAfter" -ForegroundColor Yellow

if ((Select-String -Path $filePath -Pattern "WAITING QUEUE") -ne $null) {
    Write-Host "Verified: WAITING QUEUE found - new display screen intact" -ForegroundColor Green
} else {
    Write-Host "WARNING: WAITING QUEUE not found!" -ForegroundColor Red
}

if ($countAfter -eq 1) {
    Write-Host "SUCCESS: Exactly 1 renderDisplayScreen remains" -ForegroundColor Green
} else {
    Write-Host "WARNING: $countAfter definitions remain" -ForegroundColor Red
}
