# ------------------------------------------------------------------------------
# Firewall rules for both VPCs
# Allow IAP SSH, allow internal traffic, allow ICMP for ping tests
# ------------------------------------------------------------------------------

# Hub VPC firewall rules
resource "google_compute_firewall" "hub_allow_iap_ssh" {
  name        = "${local.name_prefix}-hub-allow-iap-ssh"
  network     = google_compute_network.hub.id
  direction   = "INGRESS"
  priority    = 1000
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  description = "Allow IAP SSH to hub VPC"
}

resource "google_compute_firewall" "hub_allow_internal" {
  name        = "${local.name_prefix}-hub-allow-internal"
  network     = google_compute_network.hub.id
  direction   = "INGRESS"
  priority    = 1001
  source_ranges = [local.hub_subnet_cidr]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  description = "Allow internal traffic within hub VPC"
}

# On-prem VPC firewall rules
resource "google_compute_firewall" "onprem_allow_iap_ssh" {
  name        = "${local.name_prefix}-onprem-allow-iap-ssh"
  network     = google_compute_network.onprem.id
  direction   = "INGRESS"
  priority    = 1000
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  description = "Allow IAP SSH to on-prem VPC"
}

resource "google_compute_firewall" "onprem_allow_internal" {
  name        = "${local.name_prefix}-onprem-allow-internal"
  network     = google_compute_network.onprem.id
  direction   = "INGRESS"
  priority    = 1001
  source_ranges = [local.onprem_subnet_cidr]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  description = "Allow internal traffic within on-prem VPC"
}

# Allow traffic from VPN peer subnets (BGP-learned routes)
resource "google_compute_firewall" "hub_allow_vpn_onprem" {
  name        = "${local.name_prefix}-hub-allow-vpn"
  network     = google_compute_network.hub.id
  direction   = "INGRESS"
  priority    = 1002
  source_ranges = [local.onprem_subnet_cidr]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  description = "Allow traffic from on-prem subnet over VPN"
}

resource "google_compute_firewall" "onprem_allow_vpn_hub" {
  name        = "${local.name_prefix}-onprem-allow-vpn"
  network     = google_compute_network.onprem.id
  direction   = "INGRESS"
  priority    = 1002
  source_ranges = [local.hub_subnet_cidr]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  description = "Allow traffic from hub subnet over VPN"
}
