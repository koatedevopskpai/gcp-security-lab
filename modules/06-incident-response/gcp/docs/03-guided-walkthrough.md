# SDCI Lab 06 — GCP: Guided Walkthrough

## Step 1 — Deploy

```powershell
cd modules\06-incident-response\gcp\terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=student@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=student@example.com" -auto-approve
```

## Step 2 — Verify Normal vs Quarantined Access

```bash
# Get IPs
$cleanIp = $(terraform output -raw vm_clean_ip)
$quarIp  = $(terraform output -raw vm_quarantined_ip)

# This works — VM has ssh-allowed tag
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ~/.ssh/id_rsa sdciadmin@$cleanIp "echo 'ACCESSIBLE'"

# This TIMES OUT — VM has quarantine tag, deny-all at priority 900
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ~/.ssh/id_rsa sdciadmin@$quarIp "echo 'SHOULD NOT REACH'"
# Expected: Connection timed out
```

## Step 3 — Dynamic Quarantine a Running VM

```bash
# Currently accessible
ssh -o ConnectTimeout=5 $cleanIp "echo 'still accessible'"

# Apply the quarantine tag
gcloud compute instances add-tags sdci-06-gcp-vm-clean --tags=quarantine --zone=us-central1-a

# Now inaccessible (wait 10s for propagation)
ssh -o ConnectTimeout=5 $cleanIp "echo 'should not reach'"
# Expected: Connection timed out
```

## Step 4 — Release from Quarantine

```bash
gcloud compute instances remove-tags sdci-06-gcp-vm-clean --tags=quarantine --zone=us-central1-a

# Wait 10s, then verify access restored
ssh -o ConnectTimeout=5 $cleanIp "echo 'ACCESS RESTORED'"
```

## Step 5 — Cleanup

```powershell
cd modules\06-incident-response\gcp
.\cleanup.ps1
```
