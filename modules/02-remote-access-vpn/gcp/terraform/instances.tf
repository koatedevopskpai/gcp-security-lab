# ------------------------------------------------------------------------------
# Test instances to verify VPN connectivity
# One instance in each VPC — ping across the VPN tunnel to prove it works
# ------------------------------------------------------------------------------

# Hub workload instance
resource "google_compute_instance" "hub_workload" {
  name         = local.hub_workload_name
  machine_type = "f1-micro"
  zone         = var.zone

  tags = ["hub-workload"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hub.id
    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = local.tags

  description = "Test workload in hub VPC — verify VPN connectivity to on-prem"
}

# On-prem workload instance
resource "google_compute_instance" "onprem_workload" {
  name         = local.onprem_workload_name
  machine_type = "f1-micro"
  zone         = var.zone

  tags = ["onprem-workload"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.onprem.id
    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = local.tags

  description = "Test workload in on-prem VPC — verify VPN connectivity to hub"
}
