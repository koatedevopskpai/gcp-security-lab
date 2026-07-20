# Sprint 1 — Foundation & VPC Segmentation (GCP)

**Sprint Goal**: Establish the repository scaffold, shared modules, and implement Module 01 (VPC Segmentation) for GCP. Complete the architecture, Terraform IaC, documentation, and cleanup scripts.

## Epic: Foundation & Network Segmentation

| Story | Status | Deliverable |
|-------|--------|-------------|
| 1.1 Repo scaffold | ✅ Complete | README, ARCHITECTURE.md, COST-GUIDE.md, .gitignore |
| 1.2 Shared modules | ✅ Complete | `shared/scripts/cleanup.ps1`, `shared/templates/module-scaffold.md` |
| 1.3 GCP Terraform IaC | 🔜 In Progress | `terraform/*.tf` — VPC, subnets, firewall rules, Cloud NAT, bastion |
| 1.4 GCP docs | 📋 Planned | Architecture guide, cost analysis, guided walkthrough |
| 1.5 Git repository | 📋 Planned | Initialize git, commit, push to `github.com/koate-kpai/gcp-security-lab` |

## Key Decisions Made

1. **Three-tier mapping**: Access → `access` subnet, Distribution → firewall rule boundary, Core → `core` subnet
2. **Cloud NAT**: Only paid resource (~$0.04/day). Required for private instance egress. Flagged with cost warning.
3. **Local state**: Personal accounts don't have shared backends. Local state is simpler for training.
4. **Bastion optional**: Users can skip the bastion and use `gcloud compute ssh --tunnel-through-iap` instead.

## Cost Forecast for Sprint 1

| Resource | Daily Cost | Monthly (if left running) |
|----------|-----------|--------------------------|
| Cloud NAT | $0.04 | $1.20 |
| f1-micro bastion (free tier) | $0.00 | $0.00 |
| VPC/subnets/firewall (free) | $0.00 | $0.00 |
| **Total** | **$0.04** | **$1.20** |

## Definition of Done

- [x] Repository scaffold with README, ARCHITECTURE, COST-GUIDE
- [x] Shared cleanup script and module template
- [ ] `terraform init && terraform plan` succeeds without errors
- [ ] `terraform apply` creates VPC, 3 subnets, firewall rules, Cloud Router, Cloud NAT
- [ ] Verification steps in walkthrough produce expected results
- [ ] `terraform destroy` cleans up all resources cleanly
- [ ] Git repo initialized and pushed

## Next Steps (Sprint 2)

- Mirror Module 01 for AWS
- Start Module 02 (Remote Access VPN) for GCP
