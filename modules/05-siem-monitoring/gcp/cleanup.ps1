# Cleanup — SDCI Lab 05 (GCP)
param([switch]$AutoApprove)
$ErrorActionPreference = "Stop"
$confirm = $AutoApprove -or ((Read-Host "Destroy all resources? (yes/no)") -eq "yes")
if (-not $confirm) { Write-Host "Aborted."; exit }
terraform destroy -auto-approve
Write-Host "Cleanup complete."
