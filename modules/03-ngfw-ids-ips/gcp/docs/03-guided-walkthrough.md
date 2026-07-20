# Module 03: NGFW & IDS/IPS — Guided Walkthrough (GCP)

**Time**: 40 min | **Cost**: ~$0.05 (2-hr session)

---

## Step 1: Deploy

```powershell
cd terraform
terraform init
terraform plan      # Review resources + cost
terraform apply -auto-approve
```

Expected: ~15 resources created. Wait 2-3 minutes for the LB and MIG to provision.

---

## Step 2: Test Cloud Armor WAF

```bash
LB_IP=$(terraform output -raw lb_ip_address)

# Normal request — should succeed
curl -v http://$LB_IP
# Expected: HTTP 200, HTML response from nginx

# SQL injection — should be blocked
curl -v "http://$LB_IP?id=1' OR '1'='1"
# Expected: HTTP 403, blocked by Cloud Armor

# XSS attempt — should be blocked
curl -v "http://$LB_IP?q=<script>alert('xss')</script>"
# Expected: HTTP 403

# Protocol attack (LFI) — should be blocked
curl -v "http://$LB_IP?file=../../../etc/passwd"
# Expected: HTTP 403
```

---

## Step 3: Verify Zone-Based Firewall Rules

```bash
# Deploy a test instance in the app subnet
gcloud compute instances create sdci-03-gcp-test-app `
  --zone=us-central1-a `
  --subnet=sdci-03-gcp-snet-app `
  --tags=app-tier `
  --no-address `
  --machine-type=f1-micro `
  --image-family=ubuntu-2204-lts

# Try to SSH via IAP (should succeed — IAP rule exists)
gcloud compute ssh sdci-03-gcp-test-app --tunnel-through-iap --zone=us-central1-a

# From the web instances, try reaching the app instance on port 80 (should succeed)
# From the internet, try reaching the app instance directly (should fail — default-deny)
```

---

## Step 4: Clean Up

```powershell
gcloud compute instances delete sdci-03-gcp-test-app --zone=us-central1-a -q
terraform destroy -auto-approve
.\cleanup.ps1 -AutoApprove
```
