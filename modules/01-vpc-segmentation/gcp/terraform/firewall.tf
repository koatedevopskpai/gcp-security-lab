# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# firewall.tf
#
# ZONE-BASED FIREWALL RULES
#
# These firewall rules enforce the segmentation model. The key design principle
# is DEFAULT DENY — no cross-subnet traffic is allowed unless explicitly
# permitted by a rule.
#
# RULE HIERARCHY (priority order, lower number = higher priority):
#   1000 — deny all ingress (catch-all)
#   1001 — allow IAP SSH (required for gcloud SSH without public IPs)
#   1002 — allow internal traffic (VPC-wide internal communication)
#   1003 — allow bastion SSH to distribution/core subnets
#   1004 — deny access-to-core (simulates lateral movement prevention)
#   65535 — allow egress (default allow for outbound)
#
# MICRO-SEGMENTATION VIA TAGS:
# GCP firewall rules support target_tags and source_tags, which act like
# VLAN tagging in the Cisco world. An instance with tag "access-tier" can
# have different firewall rules than an instance with tag "iot-tier" or
# "ot-tier", even in the same subnet. This is our micro-segmentation mechanism.
#
# COST: All firewall rules are free in GCP. No charge applies.
# ------------------------------------------------------------------------------

# -------------------------------------------------------------------
# RULE: Deny all ingress (priority 1000)
# This is our default-deny stance. Any traffic not explicitly allowed
# by a lower-numbered rule is blocked. This enforces the Zero Trust
# principle of "deny by default."
# -------------------------------------------------------------------
resource "google_compute_firewall" "deny_all_ingress" {
  name        = local.fw_deny_all_ingress
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1000
  source_ranges = ["0.0.0.0/0"]
  deny {
    protocol = "all"
  }
  description = "Default deny all ingress — Zero Trust enforcement"
}

# -------------------------------------------------------------------
# RULE: Allow IAP SSH (priority 1001)
# Identity-Aware Proxy (IAP) TCP forwarding lets you SSH to instances
# without a public IP or bastion. The source range is GCP's documented
# IAP range. This is the recommended way to access VMs in GCP.
# Source: https://cloud.google.com/iap/docs/using-tcp-forwarding
# -------------------------------------------------------------------
resource "google_compute_firewall" "allow_iap_ssh" {
  name        = local.fw_allow_iap_ssh
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1001
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  description = "Allow SSH via IAP TCP forwarding (35.235.240.0/20)"
}

# -------------------------------------------------------------------
# RULE: Allow internal traffic (priority 1002)
# Allows traffic within the VPC on common ports. This is intentionally
# broad to simulate an internal trusted zone. In later modules, we
# narrow this down with micro-segmentation.
# -------------------------------------------------------------------
resource "google_compute_firewall" "allow_internal" {
  name        = local.fw_allow_internal
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1002
  source_ranges = [
    var.ip_ranges.access,
    var.ip_ranges.distribution,
    var.ip_ranges.core,
  ]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389", "8080", "8443"]
  }
  allow {
    protocol = "udp"
    ports    = ["53", "67", "68", "123"]
  }
  description = "Allow internal traffic across all three tiers on common ports"
}

# -------------------------------------------------------------------
# RULE: Allow bastion SSH (priority 1003)
# If the bastion is enabled, allow SSH from the bastion to instances
# in the distribution and core subnets. The bastion's network tag
# "bastion-tier" is matched by target_tags on this rule.
# -------------------------------------------------------------------
resource "google_compute_firewall" "allow_bastion_ssh" {
  count       = var.enable_bastion ? 1 : 0
  name        = local.fw_allow_bastion_ssh
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1003
  source_tags = ["bastion-tier"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  description = "Allow SSH from bastion host to distribution and core subnets"
}

# -------------------------------------------------------------------
# RULE: Deny access-tier to core (priority 1004)
# This simulates lateral movement prevention. Instances tagged as
# "access-tier" (end-user devices) are blocked from initiating traffic
# to the core subnet. This enforces the principle that compromised
# user endpoints should not reach backend systems directly.
# -------------------------------------------------------------------
resource "google_compute_firewall" "deny_access_to_core" {
  name        = local.fw_deny_access_to_core
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1004
  source_tags = ["access-tier"]
  target_tags = ["core-tier"]
  deny {
    protocol = "all"
  }
  description = "Block access-tier → core-tier (lateral movement prevention)"
}

# -------------------------------------------------------------------
# RULE: Allow egress (priority 65535)
# Outbound traffic is allowed by default. This is a convenience rule
# for the lab. In production, you would restrict egress to specific
# protocols and destinations.
# -------------------------------------------------------------------
resource "google_compute_firewall" "allow_egress" {
  name        = local.fw_allow_egress
  network     = google_compute_network.main.id
  direction   = "EGRESS"
  priority    = 65535
  allow {
    protocol = "all"
  }
  description = "Allow all egress traffic (default allow for lab convenience)"
}
