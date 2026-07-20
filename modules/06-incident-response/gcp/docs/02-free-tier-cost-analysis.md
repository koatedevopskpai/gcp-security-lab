# SDCI Lab 06 — GCP: Free Tier & Cost Analysis

Per-Resource Breakdown

| Resource | Daily Cost | Free Tier |
|----------|-----------|-----------|
| VPC + Subnet | $0.00 | Always free |
| Firewall Rules (3) | $0.00 | Always free |
| Cloud NAT | ~$0.04 | — |
| f1-micro VM × 2 | $0.00 | 1 per month free |
| Boot disk 10 GB × 2 | ~$0.01 | 30 GB free |

Total: **~$0.05/day**

Cost Optimization: The quarantine tag mechanism costs nothing — it's just a metadata change. No additional resources needed for incident response.
