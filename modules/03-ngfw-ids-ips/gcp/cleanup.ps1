param([switch]$AutoApprove = $false)

$modulePath = Join-Path $PSScriptRoot "terraform"

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  SDCI Lab 03 — NGFW/IDS Cleanup (GCP)             ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow

Push-Location $modulePath
try {
    & terraform state list 2>$null
    if (-not $AutoApprove) {
        $confirm = Read-Host "Type 'yes' to destroy"
        if ($confirm -ne "yes") { return }
    }
    & terraform destroy -auto-approve
    Write-Host "`n✓ Cleanup complete!" -ForegroundColor Green
    Write-Host "Check: gcloud compute security-policies list" -ForegroundColor White
}
finally { Pop-Location }
