# Module 01: VPC Segmentation — Cost Analysis

## Cost Philosophy

This lab is designed for **free tier first**. The only non-free resource is Cloud NAT at ~$0.04/day. All other resources are covered by the GCP Always Free tier or are genuinely free (VPC, subnets, firewall rules).

## Resource Cost Breakdown

| Resource | GCP Service | Free Tier? | Daily Cost | Monthly Cost | Notes |
|----------|------------|-----------|------------|-------------|-------|
| VPC | `google_compute_network` | ✅ Always free | $0.00 | $0.00 | No charge for VPCs in GCP |
| Subnet (access) | `google_compute_subnetwork` | ✅ Always free | $0.00 | $0.00 | Subnets are free per VPC |
| Subnet (distribution) | `google_compute_subnetwork` | ✅ Always free | $0.00 | $0.00 | |
| Subnet (core) | `google_compute_subnetwork` | ✅ Always free | $0.00 | $0.00 | |
| Firewall rules (6) | `google_compute_firewall` | ✅ Always free | $0.00 | $0.00 | Free regardless of count |
| Cloud Router | `google_compute_router` | ✅ Always free | $0.00 | $0.00 | No charge without VPN tunnels |
| Cloud NAT | `google_compute_router_nat` | ❌ **Not free** | **$0.04** | **$1.20** | $0.045/hour + data processing |
| f1-micro bastion | `google_compute_instance` | ✅ Free tier* | $0.00 | $0.00 | One per billing account |
| Service account | `google_service_account` | ✅ Always free | $0.00 | $0.00 | |
| **Total** | | | **$0.04** | **$1.20** | |

*\*Free tier f1-micro: one instance per billing account, 30 GB HDD, limited to specific regions.*

## Budget Cap Compliance

The daily budget cap is **$1.00 per lab**. This lab costs **$0.04/day** — well within limits.

## Cost Optimization Tips

1. **Skip Cloud NAT if not needed**: If your lab exercise doesn't require internet from private instances, set `enable_nat = false` in `terraform.tfvars`.

2. **Skip the bastion**: Use IAP TCP forwarding instead. Add `enable_bastion = false` to save your one free f1-micro for another module.

3. **Destroy immediately after lab**: The Cloud NAT cost is per-hour. A 2-hour session costs $0.004 (less than half a cent).

4. **Use GCP Budget alerts**: Before running any lab, set up a budget alert:

```bash
gcloud billing budgets create \
  --billing-account=YOUR_BILLING_ACCOUNT \
  --display-name="SDCI-Lab-Budget" \
  --budget-amount=10 \
  --alert-threshold-rule=0.5 \
  --alert-threshold-rule=0.9
```

## FinOps Tagging

Every resource carries these labels for cost tracking:

| Label | Value | Use in Billing |
|-------|-------|----------------|
| `CostCenter` | `SDCI-Lab` | Filter all lab costs |
| `Environment` | `Training` | Exclude from production reports |
| `Module` | `01-vpc-segmentation` | Per-module cost breakdown |
| `Cloud` | `gcp` | Cross-cloud comparison |
| `Creator` | your-email | Who to bill/contact |
| `DestroyAfter` | 2026-08-20 | Cleanup reminder date |

Run this query in GCP Billing → Reports to see all lab costs:

```
labels.CostCenter = "SDCI-Lab" AND labels.Module = "01-vpc-segmentation"
```

## If Budget Exceeds $1/Day

The only way this lab exceeds $1/day is if:
- You have multiple f1-micro instances running (only one is free)
- You leave Cloud NAT running for weeks (unlikely at $0.04/day)

In either case, `terraform destroy` resolves it immediately.
