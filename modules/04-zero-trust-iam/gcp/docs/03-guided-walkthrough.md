# SDCI Lab 04 — GCP: Guided Walkthrough

## Prerequisites

- GCP project with billing enabled
- `gcloud` CLI installed and authenticated (`gcloud auth login` + `gcloud auth application-default login`)
- Terraform ≥ 1.6
- IAP API enabled: `gcloud services enable iap.googleapis.com`
- Permissions to create IAM roles, service accounts, VMs, and buckets

## Step 1 — Deploy Infrastructure

```powershell
cd modules\04-zero-trust-iam\gcp\terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=student@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=student@example.com" -auto-approve
```

**Expected output**: `Apply complete! Resources: <N> added.`

## Step 2 — Access the VM via IAP (Zero Trust)

The VM has no public IP. You must use IAP TCP forwarding:

```bash
gcloud compute ssh sdci-04-gcp-vm --zone us-central1-a --tunnel-through-iap
```

**What happens behind the scenes:**
1. `gcloud` authenticates you via your Google identity
2. IAP checks that you have the `roles/iap.tunnelResourceAccessor` role
3. IAP forwards the SSH session to the VM via Google's infrastructure
4. The VM sees the connection from 35.235.240.0/20 (IAP range)
5. The VM's firewall rule allows SSH from that range

## Step 3 — Verify Least-Privilege IAM

Once logged into the VM, test what the service account can and cannot do:

```bash
# What the SA CAN do — list bucket contents
gcloud storage ls gs://sdci-04-gcp-bucket-<project-id>

# What the SA CANNOT do — create an object (should fail)
echo "test" | gcloud storage cp - gs://sdci-04-gcp-bucket-<project-id>/test.txt
# Expected: AccessDenied — the custom role doesn't include storage.objects.create

# What the SA CANNOT do — delete the bucket
gcloud storage rm gs://sdci-04-gcp-bucket-<project-id>
# Expected: AccessDenied
```

## Step 4 — Verify No Public IP

From outside GCP, try to SSH directly to the VM:

```bash
# This should fail — no public IP
gcloud compute ssh sdci-04-gcp-vm --zone us-central1-a
# Without --tunnel-through-iap, gcloud will fail to connect
```

Check in the console: Compute Engine → VM instances → `sdci-04-gcp-vm` → **External IP: None**.

## Step 5 — Examine IAM Configuration

```bash
# View the custom role definition
gcloud iam roles describe projects/YOUR_PROJECT/roles/sdci_04_gcp_custom_role

# View the service account
gcloud iam service-accounts describe sdci-04-gcp-sa@YOUR_PROJECT.iam.gserviceaccount.com

# View IAM policy on the bucket
gcloud storage buckets get-iam-policy gs://sdci-04-gcp-bucket-<project-id>
```

## Step 6 — Simulate a Zero Trust Scenario (Optional)

Grant another user IAP access and verify they can reach the VM without VPN:

```bash
# Grant IAP tunnel access (replace other-user@example.com)
gcloud projects add-iam-policy-binding YOUR_PROJECT \
  --member="user:other-user@example.com" \
  --role="roles/iap.tunnelResourceAccessor"
```

The other user can now `gcloud compute ssh` via IAP — with zero networking setup.

## Step 7 — Cleanup

```powershell
cd modules\04-zero-trust-iam\gcp
.\cleanup.ps1
```

Verify in GCP Console: all resources removed.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `gcloud compute ssh` hangs | IAP API not enabled: `gcloud services enable iap.googleapis.com` |
| `AccessDenied` on IAP SSH | You need `roles/iap.tunnelResourceAccessor` on the project or the VM |
| `Permission denied` when listing bucket | Custom role may not be bound correctly; check `gcloud projects get-iam-policy` |
| `ERROR: (gcloud.compute.ssh) Could not fetch resource` | VM not running or wrong zone |
| IAP connection times out | Firewall rule missing tag `iap-ssh` on the VM |
