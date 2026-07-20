# Module 02: Remote Access VPN — Cost Analysis (GCP)

## Cost Breakdown

| Resource | Free Tier? | Daily Cost | Notes |
|----------|-----------|------------|-------|
| Hub VPC + subnets | ✅ Always free | $0.00 | |
| On-prem VPC + subnets | ✅ Always free | $0.00 | |
| Cloud Routers (2) | ✅ Always free | $0.00 | No charge without VPN |
| HA VPN Gateway | ✅ Always free | $0.00 | Gateway itself is free |
| VPN Tunnel (1) | ✅ Free (1 per region) | $0.00 | Additional tunnels: ~$0.05/hr |
| f1-micro instances (2) | ✅ Free tier | $0.00 | One free per billing account |
| Firewall rules (6) | ✅ Always free | $0.00 | |
| **Total** | | **$0.00/day** | |

## Budget Cap: $0.00/day

This module is entirely within the GCP free tier when using 1 VPN tunnel. Production deployments should use 2 tunnels for HA ($0.05/hr each).
