param(
    [Parameter(Mandatory = $false)]
    [string]$ModulePath = ".",
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove = $false
)

<#
.SYNOPSIS
    Universal cleanup script for GCP Security Lab modules.
.DESCRIPTION
    Destroys all Terraform-managed resources in the module, prints a cost
    summary, and reminds the user to check for orphaned resources.
.EXAMPLE
    .\cleanup.ps1 -ModulePath "modules/01-vpc-segmentation/gcp/terraform" -AutoApprove
#>

function Write-WarningBanner {
    Write-Host "`n============================================" -ForegroundColor Yellow
    Write-Host "   SDCI GCP Security Lab — Cleanup"        -ForegroundColor Yellow
    Write-Host "============================================`n" -ForegroundColor Yellow
}

function Get-ResourceSummary {
    param([string]$StateDir)
    Write-Host "Resources currently managed by Terraform:" -ForegroundColor Cyan
    & terraform state list 2>$null | ForEach-Object { Write-Host "  $_" }
}

function Invoke-TerraformDestroy {
    param([string]$Dir, [bool]$AutoApprove)
    Push-Location $Dir
    try {
        if ($AutoApprove) {
            terraform destroy -auto-approve
        } else {
            Read-Host "Press ENTER to proceed with destruction (Ctrl+C to abort)"
            terraform destroy -auto-approve
        }
    }
    finally {
        Pop-Location
    }
}

function Show-PostCleanupInstructions {
    Write-Host "`n=== Post-Cleanup Checklist ===" -ForegroundColor Green
    Write-Host "  1. Check GCP Billing: https://console.cloud.google.com/billing" -ForegroundColor White
    Write-Host "  2. Verify no orphaned resources: gcloud asset search-all-resources" -ForegroundColor White
    Write-Host "  3. If no other labs remain, delete the project:" -ForegroundColor White
    Write-Host "     gcloud projects delete PROJECT_ID" -ForegroundColor White
    Write-Host "  4. Remove local state: Remove-Item -Recurse -Force .terraform/`n" -ForegroundColor White
}

# --- Main ---
Write-WarningBanner
$targetDir = Resolve-Path $ModulePath
Write-Host "Module: $targetDir`n" -ForegroundColor Cyan

Get-ResourceSummary -StateDir $targetDir

Write-Host "`nWARNING: This will DESTROY all resources in this module." -ForegroundColor Red -BackgroundColor Black
if (Test-Path "$targetDir\cost-estimate.tf") {
    Write-Host "Review the cost-estimate.tf for resources that will be destroyed.`n" -ForegroundColor Yellow
}

Invoke-TerraformDestroy -Dir $targetDir -AutoApprove $AutoApprove
Show-PostCleanupInstructions
