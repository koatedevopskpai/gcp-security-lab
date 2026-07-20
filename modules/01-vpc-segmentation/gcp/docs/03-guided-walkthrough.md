# Module 01: VPC Segmentation — Guided Walkthrough

**Estimated time**: 45 minutes  
**Daily cost**: ~$0.04 (with Cloud NAT)  
**Prerequisites**: gcloud CLI, Terraform >= 1.6, GCP project with billing enabled

---

## Step 0: Before You Start

### Cost Warning

This lab uses **Cloud NAT** which costs ~$0.04/day and is **not covered by the GCP free tier**. If you leave it running for a week, that's ~$0.28. Not expensive, but avoidable. **Always run `terraform destroy` when you finish.**

### Verify Prerequisites

```powershell
# Check gcloud is installed and authenticated
gcloud auth application-default login

# Check Terraform
terraform --version   # Should be >= 1.6

# Set your project ID
$env:TF_VAR_project_id = "your-project-id"
$env:TF_VAR_creator = "your.email@example.com"
```

**OPINION**: Use environment variables (`TF_VAR_`) instead of a `terraform.tfvars` file. This keeps your project ID out of version control.

### Create a Budget Alert (Recommended)

```bash
gcloud billing budgets create \
  --billing-account=$(gcloud billing accounts list --format="value(name)" --limit=1) \
  --display-name="SDCI-Lab-Budget" \
  --budget-amount=10 \
  --alert-threshold-rule=0.5 \
  --alert-threshold-rule=0.9
```

---

## Step 1: Understand the Architecture

Before deploying, read `01-introduction-and-architecture.md` in this directory. It explains:

- How the Cisco three-tier model maps to GCP subnets and firewall rules
- Why we use tags instead of VLANs for micro-segmentation
- The traffic flow and rule priority

**Key takeaway**: You're building a segmented network where access-tier instances cannot talk to core-tier instances. This simulates the lateral movement prevention you'd configure in a Cisco network with ACLs and VRFs.

---

## Step 2: Review the Cost Estimate

```powershell
cd terraform
terraform init
```

You'll see Terraform download the Google provider. Now run a plan:

```powershell
terraform plan
```

Look for the **Cost Estimate** table printed by `cost-estimate.tf`:

```
╔══════════════════════════════════════════════════════════════╗
║  COST ESTIMATE — SDCI Lab 01: VPC Segmentation (GCP)       ║
╠══════════════════════════════════════════════════════════════╣
║ Resource                       Qty    Rate/Day    Free Tier ║
║ ──────────────────────────────────────────────────────────── ║
║ VPC                             1     $0.00       Yes       ║
║ Subnets (access/dist/core)      3     $0.00       Yes       ║
║ Firewall rules                  6     $0.00       Yes       ║
║ Cloud Router                    1     $0.00       Yes       ║
║ Cloud NAT                       1     $0.04       No  ***   ║
║ f1-micro bastion                1     $0.00       Yes       ║
║ ──────────────────────────────────────────────────────────── ║
║  TOTAL                          -     $0.04                 ║
╚══════════════════════════════════════════════════════════════╝
```

**This is your daily maximum**. If $0.04 is acceptable, proceed.

---

## Step 3: Deploy the Network Infrastructure

```powershell
terraform apply -auto-approve
```

Terraform will create 10-12 resources. The output will look like:

```
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:
bastion_ssh_command = "gcloud compute ssh sdci-01-gcp-bastion --tunnel-through-iap --project=xxx --zone=us-central1-a"
subnet_access_cidr = "10.0.1.0/24"
subnet_core_cidr = "10.0.3.0/24"
subnet_distribution_cidr = "10.0.2.0/24"
vpc_name = "sdci-01-gcp-vpc"
```

### What Was Created?

1. **VPC** (`sdci-01-gcp-vpc`) — the isolated network
2. **Access subnet** (10.0.1.0/24) — bastion host and end-user simulation
3. **Distribution subnet** (10.0.2.0/24) — policy enforcement zone
4. **Core subnet** (10.0.3.0/24) — backend services zone
5. **Cloud Router** — required for Cloud NAT
6. **Cloud NAT** — outbound internet for private instances
7. **6 firewall rules** — default-deny, allow IAP, allow internal, allow bastion SSH, deny access→core, allow egress
8. **Bastion host** (optional) — f1-micro in the access subnet
9. **Service account** — for the bastion host

---

## Step 4: Verify Segmentation (The Core Test)

Now we prove that the segmentation works. We'll deploy two test instances and verify they can/cannot communicate as expected.

### 4.1 Deploy Test Instances

```powershell
# Deploy a core-tier instance (simulates a backend server)
gcloud compute instances create sdci-01-gcp-test-core `
  --zone=us-central1-a `
  --subnet=sdci-01-gcp-subnet-core `
  --tags=core-tier `
  --no-address `
  --machine-type=f1-micro `
  --image-family=ubuntu-2204-lts `
  --image-project=ubuntu-os-cloud `
  --labels=CostCenter=SDCI-Lab,Module=01-vpc-segmentation,Creator=test

# Deploy an access-tier instance (simulates an end-user device)
gcloud compute instances create sdci-01-gcp-test-access `
  --zone=us-central1-a `
  --subnet=sdci-01-gcp-subnet-access `
  --tags=access-tier `
  --no-address `
  --machine-type=f1-micro `
  --image-family=ubuntu-2204-lts `
  --image-project=ubuntu-os-cloud `
  --labels=CostCenter=SDCI-Lab,Module=01-vpc-segmentation,Creator=test
```

### 4.2 Get Private IPs

```powershell
$coreIp = gcloud compute instances describe sdci-01-gcp-test-core `
  --zone=us-central1-a `
  --format="get(networkInterfaces[0].networkIP)"

$accessIp = gcloud compute instances describe sdci-01-gcp-test-access `
  --zone=us-central1-a `
  --format="get(networkInterfaces[0].networkIP)"

Write-Host "Core IP: $coreIp"
Write-Host "Access IP: $accessIp"
```

### 4.3 Test 1: Bastion → Core (Should SUCCEED)

```powershell
# SSH into the bastion
gcloud compute ssh sdci-01-gcp-bastion --tunnel-through-iap --zone=us-central1-a

# From the bastion, ping the core instance
ping -c 2 $coreIp
```

**Expected result**: Ping succeeds. The bastion (tagged `bastion-tier`) is allowed by rule `allow_bastion_ssh` (priority 1003).

### 4.4 Test 2: Access-Tier → Core (Should FAIL)

Open a **second terminal** (or exit the bastion SSH session):

```powershell
# SSH into the access-tier test instance
gcloud compute ssh sdci-01-gcp-test-access --tunnel-through-iap --zone=us-central1-a

# From the access-tier instance, try to ping the core instance
ping -c 2 $coreIp
```

**Expected result**: Ping fails (request timeout). The `deny_access_to_core` rule (priority 1004) blocks all traffic from `access-tier` tagged instances to `core-tier` tagged instances.

**This is lateral movement prevention in action.** An attacker who compromises an end-user workstation (access-tier) cannot pivot to backend servers (core-tier).

### 4.5 Test 3: Access-Tier → Distribution (Should SUCCEED)

```powershell
# From the access-tier instance, try to ping a distribution subnet IP
# (If you have a test instance there, otherwise construct a nearby IP)
# This should succeed because the deny rule only targets core-tier.
```

**Expected result**: Ping succeeds. The `allow_internal` rule (priority 1002) permits cross-tier traffic on common ports. Only traffic specifically tagged as `access-tier → core-tier` is blocked.

---

## Step 5: Verify Firewall Rule Hits in Cloud Logging

```powershell
# Check firewall rule hits for the deny rule
gcloud logging read "resource.type=gce_subnetwork AND
  jsonPayload.rule_direction=INGRESS AND
  jsonPayload.disposition=DENY" --limit=10 --format=json
```

This shows you which rules are being triggered. The `deny_access_to_core` rule should appear when you attempted the ping from the access-tier instance.

---

## Step 6: Clean Up

### Destroy ALL Resources

```powershell
# First, the test instances
gcloud compute instances delete sdci-01-gcp-test-core --zone=us-central1-a -q
gcloud compute instances delete sdci-01-gcp-test-access --zone=us-central1-a -q

# Then, Terraform-managed resources
terraform destroy -auto-approve
```

### Run the Cleanup Script

```powershell
# From the gcp module directory
.\cleanup.ps1 -AutoApprove
```

The script will:
1. Confirm destruction
2. Run `terraform destroy`
3. Print a post-cleanup checklist

### Verify Cleanup

```powershell
# Check for any remaining lab resources
gcloud asset search-all-resources --query="labels.CostCenter=SDCI-Lab"
```

If this returns nothing, you're clean. If you see resources, the project may have other labs running. Check by module:

```powershell
gcloud asset search-all-resources --query="labels.Module=01-vpc-segmentation"
```

---

## Troubleshooting

| Problem | Likely Cause | Solution |
|---------|-------------|----------|
| `terraform init` fails | Provider version mismatch | Check Terraform >= 1.6. Run `terraform init -upgrade` |
| `terraform apply` fails on IAP SSH rule | IAP API not enabled | `gcloud services enable iap.googleapis.com` |
| Bastion SSH fails with "permission denied" | OS Login not enabled | `gcloud compute project-info add-metadata --metadata enable-oslogin=TRUE` |
| Ping from access-tier works when it shouldn't | Instance missing `access-tier` tag | Check tags: `gcloud compute instances describe INSTANCE --format="get(tags.items)"` |
| Cloud NAT not working | Router not in correct region | Verify router region matches subnets. Check Cloud NAT logs. |
| Cost estimate not printing | PowerShell execution policy | `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` |

---

## What You've Learned

By completing this lab, you've:

1. ✅ Translated the Cisco three-tier network model to GCP
2. ✅ Deployed a segmented VPC with three subnets
3. ✅ Enforced zone-based firewall rules with tag-based micro-segmentation
4. ✅ Configured Cloud NAT for private instance egress
5. ✅ Verified lateral movement prevention (access→core blocked)
6. ✅ Implemented mandatory FinOps tagging
7. ✅ Reviewed cost estimates before deploying
8. ✅ Cleaned up resources to avoid ongoing charges

These skills map directly to the **SDCI 300-745 exam objectives** on network segmentation, ACL enforcement, and layered architecture design.
