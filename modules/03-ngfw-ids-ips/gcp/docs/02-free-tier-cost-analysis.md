# Module 03: NGFW & IDS/IPS — Cost Analysis (GCP)

## Cost Breakdown

| Resource | Free Tier? | Daily Cost | 2-Hour Session |
|----------|-----------|------------|----------------|
| VPC + subnets | ✅ Always free | $0.00 | $0.00 |
| Firewall rules | ✅ Always free | $0.00 | $0.00 |
| Cloud Armor (5 rules) | ✅ Free tier | $0.00 | $0.00 |
| Cloud IDS | ⚠️ 30-day trial | $0.00 | $0.00 |
| HTTP Load Balancer | ❌ **Paid** | **$0.60** | **$0.05** |
| f1-micro instance | ✅ Free tier | $0.00 | $0.00 |
| **Total** | | **$0.60** | **$0.05** |

## Strategy

The HTTP LB is the only paid resource at ~$0.025/hr. A 2-hour session costs $0.05. Destroy immediately after use.
