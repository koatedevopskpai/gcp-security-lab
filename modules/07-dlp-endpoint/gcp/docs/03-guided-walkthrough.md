# SDCI Lab 07 — GCP: Guided Walkthrough

## Step 1 — Deploy

```powershell
cd modules\07-dlp-endpoint\gcp\terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=student@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=student@example.com" -auto-approve
```

## Step 2 — Run a DLP Inspection

```bash
$bucket = $(terraform output -raw bucket_name)
$template = $(terraform output -raw inspect_template_name)
$project = "YOUR_PROJECT"

gcloud dlp jobs create --project=$project `
  --inspect-template="projects/$project/inspectTemplates/$template" `
  --storage-config="gs://$bucket/*" `
  --min-time="1970-01-01T00:00:00Z" `
  --max-time=$(date -u +"%Y-%m-%dT%H:%M:%SZ") `
  --format="json"
```

## Step 3 — View Findings in BigQuery

```bash
bq query --project_id=$project --use_legacy_sql=false `
  "SELECT * FROM sdci_07_dlp_findings.dlp_findings LIMIT 20"
```

## Step 4 — Verify the De-identify Template

Use the Cloud Console or gcloud to test the de-identify template:

```bash
gcloud dlp text deidentify --project=$project `
  --deidentify-template="projects/$project/deidentifyTemplates/$(terraform output -raw deidentify_template_name)" `
  --content="My SSN is 123-45-6789 and my email is alice@example.com"
```

## Step 5 — Cleanup

```powershell
.\cleanup.ps1
```
