# SDCI Lab 01 — VPC Segmentation (GCP)

**Cisco SDCI 300-745 Domain**: Network segmentation & layered architecture

## Overview

This lab translates the **flat-to-layered network migration** case study from the training materials into Google Cloud Platform. You'll provision a three-tier VPC with Access, Distribution, and Core subnets, enforce zone-based firewall policies, and verify lateral movement prevention.

## Files

| File | Purpose |
|------|---------|
| `terraform/` | All Terraform IaC for this module |
| `docs/01-introduction-and-architecture.md` | Architecture deep dive and traffic flow |
| `docs/02-free-tier-cost-analysis.md` | Detailed cost breakdown |
| `docs/03-guided-walkthrough.md` | Step-by-step lab instructions |
| `cleanup.ps1` | Resource destruction and cost reconciliation |

## Quick Commands

```powershell
# Deploy
cd terraform
terraform init
terraform plan          # Review resources AND cost estimate
terraform apply         # Deploy

# Clean up
terraform destroy       # Destroy all resources
cd ..\..\cleanup.ps1    # Run post-cleanup checklist
```
