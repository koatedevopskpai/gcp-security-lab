# SDCI Lab 05 — GCP: Guided Walkthrough

## Prerequisites

- GCP project with billing, Logging + Monitoring APIs enabled
- `gcloud` CLI authenticated
- Terraform ≥ 1.6

## Step 1 — Deploy

```powershell
cd modules\05-siem-monitoring\gcp\terraform
terraform init
terraform plan -var="project_id=YOUR_PROJECT" -var="creator=student@example.com"
terraform apply -var="project_id=YOUR_PROJECT" -var="creator=student@example.com" -auto-approve
```

## Step 2 — Generate Log Traffic

From any machine, attempt SSH to the VM (it will fail — that's the point):

```bash
ssh invalid@$(terraform output -raw vm_external_ip)
# Expected: Permission denied (publickey)
```

Repeat 10-15 times to trigger the alert threshold.

## Step 3 — Examine VPC Flow Logs

Navigate to **Logging → Logs Explorer** or use the URL from `terraform output`:

```
terraform output logging_url
```

Query for VPC Flow Logs:

```
resource.type="gce_subnetwork"
jsonPayload.connection.dest_port=22
```

This shows all SSH traffic to your subnet with source IP, destination IP, port, and action.

## Step 4 — Examine Log-Based Metric

Navigate to **Logging → Log-Based Metrics** and find `sdci-05-gcp-ssh-attempts`.

- View the metric filter
- Check the **Latency** and **Usage** charts
- Labels extracted: `src_ip`, `dest_ip`, `src_port`

## Step 5 — View Alert Policy

Navigate to **Monitoring → Alerting** or use:

```
terraform output monitoring_url
```

- Find the `sdci-05-gcp-high-ssh` alert
- Check the **Configuration** tab for the threshold and condition
- View **Incidents** — if enough SSH attempts were made, you'll see a firing incident

## Step 6 — Cleanup

```powershell
cd modules\05-siem-monitoring\gcp
.\cleanup.ps1
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No flow logs appearing | Flow logs take 2-5 min to appear; generate more SSH attempts |
| Metric shows 0 | Log filter may be wrong; test in Logs Explorer first |
| Alert not firing | Threshold is 10 in 5 min; generate 15+ rapid attempts |
| `NAT` costing | Use `--tunnel-through-iap` instead if budget is tight |
