# SDCI Lab 06 — Incident Response & Containment (GCP)

Quarantine a compromised VM using GCP firewall tags. For the Cisco SDCI 300-745 exam.

## Architecture

```
Normal VM (tags: ssh-allowed)     → SSH accessible
Quarantined VM (tags: quarantine) → All traffic blocked (priority 900)
```

## Quarantine Mechanism

GCP firewall rules use priority (lower = higher). A `deny all` rule at priority 900 with `target_tags = ["quarantine"]` overrides permissive rules at priority 1000.

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=you@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=you@example.com" -auto-approve
```

## Test

```bash
# 1. SSH to clean VM — works
ssh -o StrictHostKeyChecking=no <clean_ip>

# 2. SSH to quarantined VM — TIMEOUT (blocked by quarantine rule)
ssh -o ConnectTimeout=5 <quarantined_ip>

# 3. Quarantine the clean VM dynamically
gcloud compute instances add-tags sdci-06-gcp-vm-clean --tags=quarantine --zone=us-central1-a

# 4. SSH to clean VM again — TIMEOUT (now quarantined)

# 5. Release
gcloud compute instances remove-tags sdci-06-gcp-vm-clean --tags=quarantine --zone=us-central1-a
```

## Script

```powershell
.\scripts\quarantine.ps1 -VM sdci-06-gcp-vm-clean -Zone us-central1-a -Action quarantine
```

## Cost

~$0.04/day (Cloud NAT + 2 f1-micro VMs free tier).

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
