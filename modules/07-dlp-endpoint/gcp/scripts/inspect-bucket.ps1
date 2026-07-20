# Run a one-time DLP inspection on the bucket using the created template.
# Usage: .\inspect-bucket.ps1 -ProjectId <PROJECT> -TemplateName <TEMPLATE_NAME> -Bucket <BUCKET_NAME>

param(
    [Parameter(Mandatory = $true)][string]$ProjectId,
    [Parameter(Mandatory = $true)][string]$TemplateName,
    [Parameter(Mandatory = $true)][string]$Bucket
)

$ErrorActionPreference = "Stop"

$job = gcloud dlp jobs create `
    --project=$ProjectId `
    --inspect-template=projects/$ProjectId/inspectTemplates/$TemplateName `
    --storage-config="gs://$Bucket/*" `
    --min-time="1970-01-01T00:00:00Z" `
    --max-time=$(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") `
    --format="json" | ConvertFrom-Json

Write-Host "DLP inspection job submitted: $($job.name)"
Write-Host "Check results in the GCP Console: Security > DLP > Inspection"
Write-Host "Or run: gcloud dlp jobs describe $($job.name) --project=$ProjectId"
