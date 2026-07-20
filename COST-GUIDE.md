# GCP Security Lab — Cost Guide

## FinOps Principles

1. **Free tier first** — All modules default to GCP Always Free tier resources. Paid services are used only when the learning objective requires them.
2. **Tag everything** — Every resource is tagged with `CostCenter`, `Environment`, `Module`, `Cloud`, `Creator`, and `DestroyAfter`. Use these tags in GCP Billing exports to track spend per lab.
3. **Clean up immediately** — Run `terraform destroy` and the module's `cleanup.ps1` after each session. Orphaned resources incur charges.
4. **Budget alerts** — Each module's `variables.tf` accepts a `billing_alert_threshold` variable. Set up a GCP Budget alert for your project before starting.

## Free Tier Limits (Relevant to These Labs)

| Service | Free Tier Limit | Applies to Modules |
|---------|----------------|-------------------|
| Compute Engine | 1 f1-micro instance per month (30 GB HDD) | 01, 02, 06 |
| VPC | No charge for VPCs, subnets, firewall rules | All modules |
| Cloud NAT | **Not free** — $0.04/day per gateway | 01, 02 (required for private instances) |
| Cloud VPN | 1 tunnel free per region | 02 |
| Cloud IDS | 30-day free trial | 03 |
| Security Command Center | Standard tier is free | 05, 06 |
| Cloud Logging | 50 GB/month free ingestion | All modules |
| Cloud DLP | 5 free inspections per month | 07 |

## Module 01 Cost Breakdown

| Resource | Free Tier? | Quantity | Daily Cost | Notes |
|----------|-----------|----------|------------|-------|
| VPC | ✅ Yes | 1 | $0.00 | |
| Subnets (access, dist, core) | ✅ Yes | 3 | $0.00 | |
| Firewall rules | ✅ Yes | 8 | $0.00 | |
| Cloud Router | ✅ Yes | 1 | $0.00 | |
| Cloud NAT | ❌ No | 1 | ~$0.04 | Only paid resource. **Delete when not in use.** |
| Compute f1-micro (bastion, optional) | ✅ Yes | 1 | $0.00 | Only one free per billing account |
| **Total** | | | **~$0.04/day** | |

## Monthly Forecast (All 8 Modules)

| Module | Daily Cost (max) | Monthly (30d) |
|--------|-----------------|---------------|
| 01 — VPC Segmentation | $0.04 | $1.20 |
| 02 — Remote Access VPN | $0.10 | $3.00 |
| 03 — NGFW & IDS/IPS | $0.50 (trial) | $15.00 (trial then ~$3) |
| 04 — Zero Trust IAM | $0.00 | $0.00 |
| 05 — SIEM & UEBA | $0.00 | $0.00 |
| 06 — Incident Response | $0.04 | $1.20 |
| 07 — DLP & Endpoint | $0.00 | $0.00 |
| 08 — Compliance | $0.00 | $0.00 |
| **Estimated Total** | **~$0.68/day** | **~$20.40** |

> Actual costs depend on usage duration. Run labs, verify, destroy. Don't leave infrastructure running.

## Budget Alerts

Before running any lab, create a budget alert:

```bash
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="SDCI-Lab-Budget" \
  --budget-amount=50 \
  --alert-threshold-rule=0.5 \
  --alert-threshold-rule=0.9 \
  --filter-projects="PROJECT_ID"
```

## Per-Label Cost Tracking

Use the `CostCenter=SDCI-Lab` tag in GCP Billing reports:

```
gcloud billing accounts list
gcloud billing budgets describe BUDGET_ID
```

## Cleanup Best Practices

1. Run `terraform destroy -auto-approve` — destroys all tagged resources
2. Run the module's `cleanup.ps1` — prints a summary and checks for orphaned resources
3. Verify in GCP Console: **IAM & Admin → Billing → Cost Table**
4. If no other labs are running, delete the project entirely:

```bash
gcloud projects delete PROJECT_ID
```
