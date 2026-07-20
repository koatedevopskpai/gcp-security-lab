# SDCI Lab 05 — SIEM, Monitoring & UEBA (GCP)

SIEM and monitoring lab for the Cisco SDCI 300-745 exam using GCP Cloud Logging, Monitoring, and VPC Flow Logs.

## Architecture

```
Traffic → VPC Flow Logs → Cloud Logging → Log-based Metric → Alert Policy
                                                              ↓
                                                          Notification
```

## Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| Network Monitoring | VPC Flow Logs with metadata |
| Centralized Logging | Cloud Logging with log-based metrics |
| Threat Detection | Metric counting inbound SSH attempts |
| Alerting | Cloud Monitoring alert on SSH threshold breach |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VPC/Flow Logs | ~$0.00 |
| Cloud NAT | ~$0.04 |
| f1-micro VM | $0.00 (free tier) |
| Logging/Monitoring | $0.00 (free tier) |
| **Total** | **~$0.04/day** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=you@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=you@example.com" -auto-approve
```

## Verify Monitoring Pipeline

```bash
# 1. Generate SSH logs (from anywhere)
ssh fakeuser@<VM_EXTERNAL_IP>
# (will fail — but generates VPC Flow Log entries)

# 2. Wait 5 minutes, then check the metric
# Navigate to: Metrics Explorer → logging.googleapis.com/user/sdci-05-gcp-ssh-attempts

# 3. Check alert policy
# Navigate to: Monitoring → Alerting → sdci-05-gcp-high-ssh
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
