# SDCI Lab 07 — Data Loss Prevention & Endpoint Security (GCP)

DLP lab using Google Cloud Data Loss Prevention API to inspect, classify, and redact sensitive data. For SDCI 300-745.

## Architecture

```
Sample PII Data → GCS Bucket → DLP Inspect Template → DLP Job → BigQuery Findings
                               → DLP De-identify Template
```

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=you@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=you@example.com" -auto-approve
```

## Test

```bash
# 1. Inspect the bucket manually using the created template
gcloud dlp jobs create --project=YOUR_PROJECT \
  --inspect-template="projects/YOUR_PROJECT/inspectTemplates/$(terraform output -raw inspect_template_name)" \
  --storage-config="gs://$(terraform output -raw bucket_name)/*" \
  --min-time="1970-01-01T00:00:00Z" \
  --max-time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 2. Check results in BigQuery
bq query --project_id=YOUR_PROJECT --use_legacy_sql=false \
  "SELECT * FROM sdci_07_dlp_findings.dlp_findings LIMIT 10"
```

## Cost

DLP free tier (500 GB inspect/mo). BigQuery 10 GB free. GCS minimal.

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
