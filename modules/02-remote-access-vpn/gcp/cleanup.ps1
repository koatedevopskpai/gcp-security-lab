param([switch]$AutoApprove = $false)

$modulePath = Join-Path $PSScriptRoot "terraform"

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  SDCI Lab 02 — Remote Access VPN Cleanup (GCP)    ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow

Push-Location $modulePath
try {
    Write-Host "Resources managed by Terraform:" -ForegroundColor Cyan
    & terraform state list 2>$null

    if (-not $AutoApprove) {
        $confirm = Read-Host "Type 'yes' to destroy all resources"
        if ($confirm -ne "yes") { Write-Host "Cancelled." -ForegroundColor Green; return }
    }

    & terraform destroy -auto-approve

    Write-Host "`n✓ Cleanup complete!" -ForegroundColor Green
    Write-Host "Check: gcloud compute vpn-tunnels list" -ForegroundColor White
}
finally { Pop-Location }
