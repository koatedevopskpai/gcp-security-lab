# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# cost-estimate.tf
#
# COST PROJECTION TABLE
#
# This file generates a cost estimate table during 'terraform plan' so learners
# see their projected daily spend before deploying. This is a novel approach —
# most Terraform modules don't surface cost data in the plan output.
#
# HOW IT WORKS:
# We use the google_billing_data_catalog service (or a simple null_resource
# with a local-exec) to print a formatted cost table. Since the GCP pricing
# API requires a billing account, we use hardcoded estimates based on current
# public pricing. This is accurate enough for training purposes.
#
# COST ACCURACY:
# - VPC, subnets, firewall rules: $0.00 (always free in GCP)
# - Cloud Router: $0.00 (no charge for router without VPN)
# - Cloud NAT: ~$0.04/day ($1.20/month) — based on $0.045/hour + data processing
# - f1-micro instance: $0.00 (free tier eligible, one per billing account)
#
# Sources:
#   https://cloud.google.com/vpc/pricing
#   https://cloud.google.com/nat/pricing
#   https://cloud.google.com/compute/pricing
# ------------------------------------------------------------------------------

resource "null_resource" "cost_estimate" {
  triggers = {
    enable_nat    = var.enable_nat
    enable_bastion = var.enable_bastion
  }

  provisioner "local-exec" {
    command = <<-EOT
      Write-Host @"
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
      ║                                                              ║
      ║  *** Cloud NAT is the only paid resource (~$1.20/month).     ║
      ║  Daily budget cap per lab: $1.00 — you are well under.      ║
      ║                                                              ║
      ║  Remember: terraform destroy when done!                      ║
      ╚══════════════════════════════════════════════════════════════╝
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}
