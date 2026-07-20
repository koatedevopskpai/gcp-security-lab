# SDCI Lab 04 — Zero Trust & Identity Access Management (GCP)

Zero Trust IAM lab for the Cisco SDCI 300-745 exam using GCP IAM, IAP, and Service Accounts.

## Architecture

```
Developer → IAP TCP Forwarding (Zero Trust) → Private VM (no public IP)
                                                    ↓
                                          Service Account (workload ID)
                                                    ↓
                                          GCS Bucket (least-privilege access)
```

## Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| Zero Trust Network Access | IAP TCP forwarding — SSH without public IP or VPN |
| Workload Identity | Service Account bound to Compute Engine |
| Least-Privilege IAM | Custom role with only `storage.objects.get` + `list` |
| IAM Conditions | Bucket access restricted to specific resource pattern |
| Policy-as-Code | All IAM defined in Terraform |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VPC/Subnet/Firewall | $0.00 |
| Cloud NAT | ~$0.04 |
| f1-micro VM | $0.00 (free tier) |
| Service Account / IAM | $0.00 |
| IAP TCP Forwarding | $0.00 |
| GCS Bucket | ~$0.00 |
| **Total** | **~$0.04/day** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=you@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=you@example.com" -auto-approve
```

## Access the VM (via IAP — no public IP)

```bash
gcloud compute ssh sdci-04-gcp-vm --zone us-central1-a --tunnel-through-iap
```

## Verify Zero Trust

```bash
# From within the VM — list bucket objects
gcloud storage ls gs://sdci-04-gcp-bucket-<project-id>

# Try to create an object (should fail — least privilege)
echo "test" | gcloud storage cp - gs://sdci-04-gcp-bucket-<project-id>/test.txt
# Expected: AccessDenied
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
