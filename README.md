# GCP Security Lab

Hands-on security training labs for Google Cloud Platform, aligned to **Cisco SDCI 300-745** exam objectives.

## Alignment to Cisco SDCI 300-745

This repo maps the following 300-745 domains into practical GCP implementations:

| 300-745 Domain | GCP Lab Module | Key GCP Services |
|---------------|----------------|------------------|
| Network segmentation & layered architecture | 01 - VPC Segmentation | VPC, subnets, firewall rules, Cloud NAT |
| Remote access & VPN connectivity | 02 - Remote Access VPN | Cloud VPN, Cloud Router, IAP |
| NGFW, IDS/IPS, zone-based firewalls | 03 - NGFW & IDS/IPS | Cloud NGFW, Cloud IDS, Cloud Armor |
| Zero Trust & RBAC | 04 - Zero Trust IAM | IAM, Policy Analyzer, IAP, VPC Service Controls |
| SIEM, monitoring, UEBA | 05 - SIEM & UEBA | Security Command Center, Chronicle, Cloud Logging |
| Incident response & containment | 06 - Incident Response | VPC Flow Logs, firewall tags, instance quarantine |
| DLP & endpoint security | 07 - DLP & Endpoint | Cloud DLP, OS Config, Access Transparency |
| Compliance & auditing | 08 - Compliance | Assured Workloads, Cloud Audit Logs, Org Policies |

## Prerequisites

- GCP account with billing enabled (free tier eligible)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6
- PowerShell 5.1+ (for cleanup scripts)

## Quick Start

```powershell
# Clone the repo
git clone https://github.com/koatedevopskpai/gcp-security-lab.git
cd gcp-security-lab

# Navigate to a module
cd modules/01-vpc-segmentation/gcp/terraform

# Review costs before deploying
terraform init
terraform plan

# Deploy
terraform apply -auto-approve

# Verify segmentation
gcloud compute instances list

# Clean up
terraform destroy -auto-approve
```

## Repository Structure

```
gcp-security-lab/
├── README.md
├── ARCHITECTURE.md
├── COST-GUIDE.md
├── sprints/
│   └── 01-foundation-segmentation.md
├── modules/
│   └── 01-vpc-segmentation/
│       └── gcp/
│           ├── terraform/           # IaC code
│           ├── docs/                # Architecture, cost, walkthrough
│           └── cleanup.ps1          # Module-specific cleanup
└── shared/
    ├── scripts/                    # Common utilities
    └── templates/                  # Module scaffolding
```

## Cost Management

All modules are designed for **free tier first**. Where paid resources are unavoidable, they are explicitly flagged with cost warnings. See [COST-GUIDE.md](./COST-GUIDE.md) for details.

## License

For educational and training purposes only.
