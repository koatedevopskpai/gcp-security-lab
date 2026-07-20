# SDCI Lab 05 — GCP: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VPC + Subnet | Free | $0.00 | Always free |
| VPC Flow Logs | $0.15/GB ingested | ~$0.00 | Minimal traffic |
| Firewall Rules | Free | $0.00 | Always free |
| Cloud NAT | $0.008/hr + data | ~$0.04 | — |
| f1-micro VM | $0.0075/hr | $0.00 | 1 per month free |
| Boot disk 10 GB | $0.04/GB/mo | ~$0.01 | 30 GB free |
| Cloud Logging | Free up to 50 GB/mo | $0.00 | 50 GB ingestion free |
| Log-Based Metrics | Free | $0.00 | 100 metrics free |
| Cloud Monitoring | Free up to 15 metrics | $0.00 | 15 metrics, 5 alert policies |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — Free tier | **~$0.00** | ~$0.00 |
| **Worst case** — No free tier | **~$0.05** | ~$1.50 |

## Cost vs On-Premises SIEM

| Factor | Traditional SIEM | GCP Cloud Logging |
|--------|-----------------|-------------------|
| Ingestion cost | $1-5/GB/day | $0.15/GB ingested |
| Storage | Self-managed infra | Managed, 30-day default |
| Retention | Limited by hardware | Configurable up to 3650 days |
| Alerting | Complex config | Declarative via Terraform |

## FinOps Labels

| Label | Value |
|-------|-------|
| `CostCenter` | `SDCI-Lab` |
| `Module` | `05-siem-monitoring` |
| `Cloud` | `gcp` |
| `Creator` | `<your-email>` |
