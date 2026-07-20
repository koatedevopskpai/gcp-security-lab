# ------------------------------------------------------------------------------
# SDCI Lab 04 — Zero Trust & Identity Access Management (GCP)
# main.tf
#
# Key concepts demonstrated:
#   1. Workload identity — Service Account bound to Compute Engine
#   2. Least-privilege IAM — Custom role with minimal permissions
#   3. IAM conditions — Access granted only when specified attributes match
#   4. Zero-trust network — No public IP; access via IAP TCP forwarding
#   5. Policy-as-Code — All IAM defined in Terraform
#
# ARCHITECTURE:
#   Developer → IAP (Zero Trust) → Private VM → SA reads bucket
# COST: IAP free, Cloud NAT ~$0.04/day, f1-micro VM ~$0.00/free tier
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# VPC — private subnet only (no public IP access from internet)
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
  private_ip_google_access = true
}

# --------------------------------------------------------------------------
# CLOUD NAT — outbound access for private VM (updates, APIs)
# --------------------------------------------------------------------------
resource "google_compute_router" "nat" {
  name    = local.router_name
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_router_nat" "main" {
  name   = local.nat_name
  router = google_compute_router.nat.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# --------------------------------------------------------------------------
# FIREWALL RULE — IAP TCP forwarding (22 from IAP range only)
# Zero Trust: no SSH from 0.0.0.0/0, only from Google's IAP proxy
# --------------------------------------------------------------------------
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${local.name_prefix}-allow-iap-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]
}

# --------------------------------------------------------------------------
# GCS BUCKET — resource that the service account will access
# --------------------------------------------------------------------------
resource "google_storage_bucket" "main" {
  name                        = local.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  labels                      = local.labels
}

# --------------------------------------------------------------------------
# CUSTOM IAM ROLE — least privilege (read-only on a single bucket)
# --------------------------------------------------------------------------
resource "google_project_iam_custom_role" "main" {
  role_id     = local.custom_role_id
  title       = "SDCI Lab 04 — Bucket Reader"
  description = "Least-privilege role: read objects in ${local.bucket_name}"
  permissions = [
    "storage.objects.get",
    "storage.objects.list",
  ]
}

# --------------------------------------------------------------------------
# SERVICE ACCOUNT — workload identity for the VM
# --------------------------------------------------------------------------
resource "google_service_account" "main" {
  account_id   = local.sa_name
  display_name = "SDCI Lab 04 Service Account"
}

# Grant the SA access to the custom role at the project level
resource "google_project_iam_member" "sa_custom_role" {
  role   = google_project_iam_custom_role.main.id
  member = "serviceAccount:${google_service_account.main.email}"
}

# Grant the SA access to the specific bucket (resource-level binding)
resource "google_storage_bucket_iam_member" "sa_bucket_reader" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.main.email}"

  condition {
    title       = "sdci-lab-conditional"
    description = "Only allow access from the lab VM's service account"
    expression  = "resource.name.startsWith('projects/_/buckets/${local.bucket_name}/objects/')"
  }
}

# --------------------------------------------------------------------------
# VM INSTANCE — private (no public IP), uses service account
# --------------------------------------------------------------------------
resource "google_compute_instance" "main" {
  name         = local.vm_name
  machine_type = "f1-micro"
  zone         = local.zone
  tags         = ["iap-ssh"]
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
  }

  service_account {
    email  = google_service_account.main.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
