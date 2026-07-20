param(
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove = $false
)

<#
.SYNOPSIS
    Cleanup script for SDCI Lab 01 — VPC Segmentation (GCP)
.DESCRIPTION
    Destroys all Terraform-managed resources, prints cost reconciliation,
    and reminds the user to check for orphaned resources.
.EXAMPLE
    .\cleanup.ps1 -AutoApprove
#>

$modulePath = Join-Path $PSScriptRoot "terraform"

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  SDCI Lab 01 — VPC Segmentation Cleanup (GCP)     ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Push-Location $modulePath
try {
    # Show current state
    Write-Host "Resources managed by Terraform:" -ForegroundColor Cyan
    & terraform state list 2>$null

    if (-not $AutoApprove) {
        Write-Host ""
        Write-Host "WARNING: This will destroy ALL resources in Lab 01." -ForegroundColor Red
        Write-Host "Cloud NAT (~$0.04/day) will be removed." -ForegroundColor Yellow
        $confirm = Read-Host "Type 'yes' to proceed"
        if ($confirm -ne "yes") {
            Write-Host "Cleanup cancelled." -ForegroundColor Green
            return
        }
    }

    # Destroy
    Write-Host "Running terraform destroy..." -ForegroundColor Yellow
    if ($AutoApprove) {
        & terraform destroy -auto-approve
    } else {
        & terraform destroy
    }

    Write-Host ""
    Write-Host "✓ Cleanup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Post-Cleanup Checklist ===" -ForegroundColor Cyan
    Write-Host "1. Verify in GCP Console: https://console.cloud.google.com/billing" -ForegroundColor White
    Write-Host "2. Check for orphaned resources:" -ForegroundColor White
    Write-Host "   gcloud asset search-all-resources --query='labels.CostCenter=SDCI-Lab'" -ForegroundColor White
    Write-Host "3. If no other labs remain, delete the project:" -ForegroundColor White
    Write-Host "   gcloud projects delete $((& terraform output -raw project_id 2>$null))" -ForegroundColor White
}
finally {
    Pop-Location
}
