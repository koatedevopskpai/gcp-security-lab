# ------------------------------------------------------------------------------
# SDCI Lab 05 — SIEM, Monitoring & UEBA (GCP)
# main.tf
#
# Key concepts demonstrated:
#   1. VPC Flow Logs — network traffic monitoring
#   2. Cloud Logging — centralized log storage
#   3. Log-based metrics — metrics derived from log entries
#   4. Cloud Monitoring alerts — proactive notification on suspicious activity
#
# ARCHITECTURE:
#   Traffic → VPC Flow Logs → Cloud Logging → Log Metric → Alert Policy
# COST: Flow Logs minimal, Logging free tier (50 GB), Monitoring free tier
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# VPC — subnet with VPC Flow Logs enabled
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

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# --------------------------------------------------------------------------
# CLOUD NAT — outbound access for VM
# --------------------------------------------------------------------------
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
# FIREWALL — SSH from internet (generates log entries for alerting)
# --------------------------------------------------------------------------
resource "google_compute_firewall" "allow_ssh" {
  name    = "${local.name_prefix}-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-monitored"]
}

resource "google_compute_firewall" "deny_all" {
  name    = "${local.name_prefix}-deny-all"
  network = google_compute_network.main.name

  deny {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
  priority      = 65535
}

# --------------------------------------------------------------------------
# VM — generates log entries (SSH attempts)
# --------------------------------------------------------------------------
resource "google_compute_instance" "main" {
  name         = local.vm_name
  machine_type = "f1-micro"
  zone         = local.zone
  tags         = ["ssh-monitored"]
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
    access_config {}  # public IP
  }
}

# --------------------------------------------------------------------------
# LOG-BASED METRIC — count firewall deny entries
# This creates a metric from VPC Flow Logs that counts rejected traffic
# --------------------------------------------------------------------------
resource "google_logging_metric" "ssh_attempts" {
  name        = local.metric_name
  description = "Count of SSH connection attempts (inbound tcp/22)"
  filter      = <<-EOT
    resource.type="gce_subnetwork"
    log_name="projects/${var.project_id}/logs/compute.googleapis.com%2Fvpc_flows"
    jsonPayload.connection.dest_port=22
    jsonPayload.connection.protocol=6
    jsonPayload.reporter="SRC"
  EOT
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
  label_extractors = {
    "src_ip"     = "EXTRACT(jsonPayload.connection.src_ip)"
    "dest_ip"    = "EXTRACT(jsonPayload.connection.dest_ip)"
    "src_port"   = "EXTRACT(jsonPayload.connection.src_port)"
  }
}

# --------------------------------------------------------------------------
# CLOUD MONITORING ALERT — fires when SSH attempts exceed threshold in 5 min
# --------------------------------------------------------------------------
resource "google_monitoring_alert_policy" "high_ssh" {
  display_name = local.alert_name
  combiner     = "OR"
  severity     = "WARNING"

  conditions {
    display_name = "High inbound SSH attempts"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/${local.metric_name}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 10
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_SUM"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }

  notification_channels = []
  user_labels           = local.labels
}
