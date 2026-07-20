# ------------------------------------------------------------------------------
# SDCI Lab 06 — Incident Response & Containment (GCP)
# main.tf
#
# Key concept: Dynamically quarantine a VM by applying a firewall tag.
# In GCP, firewall rules are evaluated by priority (lower = higher).
# A "deny all" rule with the `quarantine` tag at priority 900 overrides
# the permissive rules at priority 1000.
#
# Incident Response workflow:
#   1. Detect compromise (via VPC Flow Logs, alert, etc.)
#   2. Apply quarantine tag:   gcloud compute instances add-tags vm --tags=quarantine
#   3. Investigate via IAP/SSH (if responder SG still allows)
#   4. Remove quarantine tag:  gcloud compute instances remove-tags vm --tags=quarantine
#
# COST: ~$0.04/day (Cloud NAT only; VMs free tier eligible)
# --------------------------------------------------------------------------

resource "google_compute_network" "main" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "main" {
  name          = local.subnet_name
  network       = google_compute_network.main.id
  region        = var.region
  ip_cidr_range = "10.0.1.0/24"
}

# Cloud NAT for outbound access
resource "google_compute_router" "nat" {
  name    = local.router_name
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_router_nat" "main" {
  name                               = local.nat_name
  router                             = google_compute_router.nat.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# --------------------------------------------------------------------------
# FIREWALL RULES — tag-based quarantine mechanism
# Priority order (lower number = higher priority):
#   900 — Quarantine: deny all for tagged VMs (HIGH priority)
#  1000 — Normal access: allow SSH, allow internal (lower priority)
# --------------------------------------------------------------------------

# Rule 1 — Quarantine: deny all traffic for instances with "quarantine" tag
resource "google_compute_firewall" "deny_quarantine" {
  name          = "${local.name_prefix}-deny-quarantine"
  network       = google_compute_network.main.name
  priority      = 900
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  target_tags = ["quarantine"]
}

# Rule 2 — Allow SSH from anywhere (for normal operation)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${local.name_prefix}-allow-ssh"
  network = google_compute_network.main.name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"]
}

# Rule 3 — Allow internal traffic between instances
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.name_prefix}-allow-internal"
  network = google_compute_network.main.name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/16"]
  target_tags   = ["internal-allowed"]
}

# --------------------------------------------------------------------------
# VMs — demonstrate quarantine vs normal access
# --------------------------------------------------------------------------
resource "google_compute_instance" "clean" {
  name         = local.vm_clean
  machine_type = "f1-micro"
  zone         = local.zone
  tags         = ["ssh-allowed", "internal-allowed"]
  labels       = local.labels

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id
    access_config {}
  }
}

resource "google_compute_instance" "quarantined" {
  name         = local.vm_quarantined
  machine_type = "f1-micro"
  zone         = local.zone
  tags         = ["quarantine"]
  labels       = local.labels

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id
    access_config {}
  }
}
