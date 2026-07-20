# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# vpc.tf
#
# THREE-TIER VPC DESIGN
#
# GCP VPCs are global, flat networks. Unlike AWS where subnets are tied to
# availability zones, GCP subnets are regional. We simulate the Cisco
# three-tier model (Access / Distribution / Core) using three subnets within
# a single VPC, each with different firewall rules applied.
#
# TRAFFIC FLOW:
#   Access (10.0.1.0/24)  →  Distribution (10.0.2.0/24)  →  Core (10.0.3.0/24)
#       ↑                      ↑ firewall boundary ↑              ↑
#   End users             Policy enforcement              Backend / NAT egress
#
# DECISION: Single VPC, not multiple.
# Multiple VPCs would require VPC peering (up to 25 in a project). A single
# VPC with firewall rule isolation achieves the same segmentation with less
# complexity and zero additional cost. This aligns with Google's recommendation
# for most enterprise designs: one VPC per environment, subnets for segmentation.
# ------------------------------------------------------------------------------

resource "google_compute_network" "main" {
  name                    = local.vpc_name
  auto_create_subnetworks = false

  # DESCRIPTION embeds tags because GCP VPCs don't support labels.
  description = "SDCI Lab 01 — Three-tier VPC (Access/Dist/Core) | CostCenter=SDCI-Lab | Module=${var.module_name} | Cloud=gcp | Creator=${var.creator}"

  # Delete default routes on creation. We manage routing explicitly in routing.tf.
  delete_default_routes_on_create = true
}

# ACCESS SUBNET — End-user device connectivity
# Simulates the Cisco Access Layer where user endpoints connect. In a real
# enterprise, this is where workstations, printers, and phones attach.
resource "google_compute_subnetwork" "access" {
  name          = local.subnet_access
  ip_cidr_range = var.ip_ranges.access
  region        = var.region
  network       = google_compute_network.main.id

  # Private Google Access allows instances without public IPs to reach
  # Google APIs (e.g., Container Registry, Cloud Storage) without Cloud NAT.
  private_ip_google_access = true

  # GCE instances in this subnet get the "access-tier" tag by default.
  # Firewall rules use this tag to identify access-layer traffic.
  description = "Access layer subnet (simulates Cisco Access Layer) | ${var.ip_ranges.access}"

  labels = local.tags
}

# DISTRIBUTION SUBNET — Policy enforcement boundary
# Simulates the Cisco Distribution Layer where inter-VLAN routing and ACLs
# are applied. In this design, distribution-layer firewall rules terminate
# here and enforce zone-based policies.
resource "google_compute_subnetwork" "distribution" {
  name          = local.subnet_dist
  ip_cidr_range = var.ip_ranges.distribution
  region        = var.region
  network       = google_compute_network.main.id

  private_ip_google_access = true

  description = "Distribution layer subnet (policy enforcement boundary) | ${var.ip_ranges.distribution}"

  labels = local.tags
}

# CORE SUBNET — Backend / high-speed backbone
# Simulates the Cisco Core Layer. In a data center, this is where your
# databases, application servers, and NAT gateways live. Traffic here
# is trusted but tightly controlled.
resource "google_compute_subnetwork" "core" {
  name          = local.subnet_core
  ip_cidr_range = var.ip_ranges.core
  region        = var.region
  network       = google_compute_network.main.id

  private_ip_google_access = true

  description = "Core layer subnet (backend / NAT egress) | ${var.ip_ranges.core}"

  labels = local.tags
}
