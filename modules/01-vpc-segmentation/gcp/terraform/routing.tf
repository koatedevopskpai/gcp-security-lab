# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# routing.tf
#
# CLOUD ROUTER AND CLOUD NAT
#
# GCP Cloud NAT enables outbound internet connectivity for private instances
# (those without external IP addresses). This is required for:
#   - Downloading packages and updates
#   - Reaching Google APIs (though Private Google Access covers most)
#   - General internet egress
#
# DECISION: Cloud Router + Cloud NAT vs. instances with public IPs
# Using public IPs is simpler but breaks the security model — instances with
# public IPs are directly reachable from the internet (even with firewall rules,
# the attack surface is larger). Cloud NAT provides managed, secure egress.
#
# COST WARNING:
# Cloud NAT is the only non-free resource in this module. At ~$0.04/day, it is
# well under the $1/day budget cap, but it is NOT covered by the GCP free tier.
# The cost is conditional on the enable_nat variable — set to false to skip.
# ------------------------------------------------------------------------------

resource "google_compute_router" "main" {
  name    = local.router_name
  region  = var.region
  network = google_compute_network.main.id

  description = "Cloud Router for NAT — SDCI Lab 01 | Module=${var.module_name}"

  # No BGP is configured. This router exists solely to host the NAT gateway.
  # In Module 02 (VPN), we'll add BGP for dynamic routing.
}

resource "google_compute_router_nat" "main" {
  count = var.enable_nat ? 1 : 0

  name   = local.nat_name
  region = var.region
  router = google_compute_router.main.name

  # NAT all IPs in configured subnets. This is the simplest mode — all private
  # instances in the distribution and core subnets will share the NAT IP.
  nat_ip_allocate_option = "AUTO_ONLY"

  # Source subnets for NAT — only private subnets need egress.
  # The access subnet instances could also use NAT if they are private,
  # but in this lab access subnet is designed for public-facing bastion.
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.distribution.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  subnetwork {
    name                    = google_compute_subnetwork.core.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  description = "Cloud NAT for private instance egress — costs ~$0.04/day"

  # Logs for NAT traffic. Useful for debugging egress issues and for
  # security monitoring (see Module 05 — SIEM).
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
