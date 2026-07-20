# SDCI Lab 04 — GCP: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VPC + Subnet | Free | $0.00 | Always free |
| Firewall rule | Free | $0.00 | Always free |
| Cloud NAT gateway | Per GB processed + $0.008/hr | ~$0.04 | — |
| Cloud Router | Free | $0.00 | Always free |
| f1-micro VM | $0.0075/hr | $0.00 | 1 f1-micro per month free |
| Boot disk pd-standard 10 GB | $0.04/GB/mo | ~$0.01 | 30 GB free per account |
| Service Account | Free | $0.00 | Always free |
| Custom IAM Role | Free | $0.00 | Always free |
| IAP TCP Forwarding | Free for SSH/RDP | $0.00 | Always free |
| GCS Standard bucket < 1 GB | $0.020/GB/mo | ~$0.00 | 5 GB free per account |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — Free tier available | **~$0.00** | ~$0.00 |
| **Worst case** — No free tier | **~$0.05** | ~$1.50 |

## Cost Optimization Tips

1. **NAT is the only cost driver** — VM, IAM, IAP, and VPC are all free or near-free
2. **Use g1-small instead of f1-micro** if you need more RAM ($0.014/hr = $0.34/day)
3. **Destroy immediately** after lab — NAT charges even at idle
4. **IAP is free** for SSH and RDP — use it instead of a bastion host
5. **Bucket charges** apply only if you store large objects — the lab stores nothing significant

## FinOps Labels

All resources deployed with:

| Label | Value |
|-------|-------|
| `CostCenter` | `SDCI-Lab` |
| `Environment` | `Training` |
| `Module` | `04-zero-trust-iam` |
| `Cloud` | `gcp` |
| `Creator` | `<your-email>` |
| `DestroyAfter` | `<YYYY-MM-DD>` |
