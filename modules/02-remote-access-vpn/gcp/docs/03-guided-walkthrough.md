# Module 02: Remote Access VPN — Guided Walkthrough (GCP)

**Estimated time**: 50 minutes  
**Cost**: $0.00 (within free tier)

---

## Step 0: Prerequisites

- GCP project with billing enabled
- `gcloud auth application-default login`

```powershell
$env:TF_VAR_project_id = "your-project-id"
$env:TF_VAR_creator = "your@email.com"
```

---

## Step 1: Deploy

```powershell
cd terraform
terraform init
terraform plan      # Review resources + cost estimate
terraform apply -auto-approve
```

---

## Step 2: Verify VPN Tunnel Status

```bash
gcloud compute vpn-tunnels list --region us-central1
```

Expected output: tunnel status is `ESTABLISHED`.

---

## Step 3: Verify BGP Sessions

```bash
gcloud compute routers get-status sdci-02-gcp-hub-router --region us-central1
```

Expected: `bgpPeerStatus[0].status = ESTABLISHED`

---

## Step 4: Test Cross-VPC Connectivity

```bash
# Get the private IPs
HUB_IP=$(gcloud compute instances describe sdci-02-gcp-hub-vm \
  --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)')

ONPREM_IP=$(gcloud compute instances describe sdci-02-gcp-onprem-vm \
  --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)')

echo "Hub: $HUB_IP  OnPrem: $ONPREM_IP"

# SSH into hub VM
gcloud compute ssh sdci-02-gcp-hub-vm --tunnel-through-iap --zone=us-central1-a
```

From the hub VM:
```bash
ping -c 4 $ONPREM_IP
```

**Expected**: Ping succeeds. The VPN tunnel + BGP dynamically routes traffic between the VPCs.

---

## Step 5: Clean Up

```powershell
terraform destroy -auto-approve
.\cleanup.ps1 -AutoApprove
```
