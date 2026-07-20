# GCP Incident Response — Quarantine/Release a VM by tag
# Usage:
#   .\quarantine.ps1 -VM sdci-06-gcp-vm-clean -Zone us-central1-a -Action quarantine
#   .\quarantine.ps1 -VM sdci-06-gcp-vm-clean -Zone us-central1-a -Action release

param(
    [Parameter(Mandatory = $true)]
    [string]$VM,

    [Parameter(Mandatory = $true)]
    [string]$Zone,

    [ValidateSet("quarantine", "release")]
    [string]$Action
)

$ErrorActionPreference = "Stop"

if ($Action -eq "quarantine") {
    Write-Host "🔒 Quarantining $VM by adding 'quarantine' tag..."
    gcloud compute instances add-tags $VM --tags=quarantine --zone=$Zone
    Write-Host "Done. VM $VM is now isolated (deny-all rule active)."
}
else {
    Write-Host "🔓 Releasing $VM by removing 'quarantine' tag..."
    gcloud compute instances remove-tags $VM --tags=quarantine --zone=$Zone
    Write-Host "Done. VM $VM has normal network access restored."
}
