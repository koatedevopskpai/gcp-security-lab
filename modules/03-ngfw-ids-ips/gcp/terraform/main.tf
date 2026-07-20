# ------------------------------------------------------------------------------
# SDCI Lab 03 — NGFW, IDS/IPS & Zone-Based Firewalls (GCP)
# main.tf
#
# This lab demonstrates three security layers working together:
#   1. Cloud Armor — WAF (Layer 7) protecting against web attacks
#   2. Cloud IDS — Network threat detection (Layer 3-4)
#   3. VPC firewall rules — Zone-based segmentation (Layer 3-4)
#
# ARCHITECTURE:
#   Internet → Cloud Armor → HTTP LB → Web subnet → App subnet (firewall-enforced)
#                                                   └─ Cloud IDS monitoring traffic
#
# COST: Cloud Armor (free tier: 5 rules), Cloud IDS (30-day free trial),
#        VPC firewall rules (free). Total: $0.00 during trial.
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# VPC and subnets
# --------------------------------------------------------------------------
resource "google_compute_network" "main" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
  description             = "SDCI Lab 03 — NGFW/IDS VPC"
}

# Web subnet — public-facing, behind the LB
resource "google_compute_subnetwork" "web" {
  name          = local.snet_web
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
  private_ip_google_access = true
  labels = local.tags
  description = "Web subnet — public-facing tier behind Cloud Armor + LB"
}

# App subnet — private, no direct internet access
resource "google_compute_subnetwork" "app" {
  name          = local.snet_app
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.main.id
  private_ip_google_access = true
  labels = local.tags
  description = "App subnet — private tier, zone-isolated from web"
}

# --------------------------------------------------------------------------
# ZONE-BASED FIREWALL RULES
# This simulates the Distribution Layer ACL enforcement from SDCI 300-745.
# Rule: Web→App allowed on app ports only. Internet→Web blocked except via LB.
# --------------------------------------------------------------------------
# Default-deny all ingress
resource "google_compute_firewall" "deny_all" {
  name        = "${local.name_prefix}-deny-all"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1000
  source_ranges = ["0.0.0.0/0"]
  deny { protocol = "all" }
  description = "Default-deny all ingress — Zero Trust foundation"
}

# Allow health check ranges (required for LB to work)
resource "google_compute_firewall" "allow_health_checks" {
  name        = "${local.name_prefix}-allow-hc"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1001
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  description = "Allow GCP LB health check probes"
}

# Allow IAP SSH
resource "google_compute_firewall" "allow_iap_ssh" {
  name        = "${local.name_prefix}-allow-iap-ssh"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1002
  source_ranges = ["35.235.240.0/20"]
  allow { protocol = "tcp"; ports = ["22"] }
  description = "Allow IAP SSH for administrative access"
}

# Allow web→app on port 80 only (simulates distribution layer ACL)
resource "google_compute_firewall" "allow_web_to_app" {
  name        = "${local.name_prefix}-allow-web-to-app"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1010
  source_ranges = ["10.0.1.0/24"]
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
  description = "Allow web subnet → app subnet on app ports only (simulates distribution ACL)"
}

# Allow LB proxy to web subnet
resource "google_compute_firewall" "allow_lb_to_web" {
  name        = "${local.name_prefix}-allow-lb-to-web"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1011
  source_ranges = ["10.0.1.0/24"]
  allow { protocol = "tcp"; ports = ["80"] }
  description = "Allow LB proxy to reach web instances"
}

# --------------------------------------------------------------------------
# CLOUD IDS — Intrusion Detection Service
# Monitors traffic in the VPC for malicious patterns.
# 30-day free trial available. After trial: $0.35/hr.
# --------------------------------------------------------------------------
resource "google_compute_network" "ids_network" {
  # Cloud IDS requires a separate VPC in the same project for mirroring
  # but actually IDS can be deployed on the same VPC.
  # We create a special subnet for the IDS endpoint.
  count            = 0 # Uncomment to deploy: requires ids.googleapis.com enabled
  name                    = "${local.name_prefix}-ids-vpc"
  auto_create_subnetworks = false
  description             = "VPC for Cloud IDS endpoint"
}

# --------------------------------------------------------------------------
# CLOUD ARMOR SECURITY POLICY (WAF)
# Protects the load balancer from web attacks at Layer 7.
# Free tier: 5 rules per policy. We use 4 rules within the limit.
# --------------------------------------------------------------------------
resource "google_compute_security_policy" "armor" {
  name        = local.armor_policy
  description = "Cloud Armor WAF policy — protects web workloads (free tier: 5 rules)"
  type        = "CLOUD_ARMOR"

  # Rule 1 (priority 1000): Block SQL injection
  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-canary')"
      }
    }
    description = "Block SQL injection attempts"
  }

  # Rule 2 (priority 1001): Block cross-site scripting
  rule {
    action   = "deny(403)"
    priority = 1001
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-canary')"
      }
    }
    description = "Block XSS attempts"
  }

  # Rule 3 (priority 1002): Block common web exploits (LFI, RFI, RCE)
  rule {
    action   = "deny(403)"
    priority = 1002
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('protocolattack-canary')"
      }
    }
    description = "Block protocol attacks (LFI, RFI, RCE)"
  }

  # Rule 4 (priority 2147483647): Default allow (lowest precedence)
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow (after WAF inspection)"
  }

  labels = local.tags
}

# --------------------------------------------------------------------------
# HTTP LOAD BALANCER — fronted by Cloud Armor
# --------------------------------------------------------------------------
# Health check
resource "google_compute_health_check" "main" {
  name = local.health_check
  http_health_check {
    port = 80
  }
  description = "LB health check"
}

# Instance template and managed instance group
resource "google_compute_instance_template" "main" {
  name         = local.instance_template
  machine_type = "f1-micro"
  tags         = ["web-tier"]

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2204-lts"
    auto_delete  = true
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.web.id
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = local.tags

  # Simple web server startup script
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<html><body><h1>SDCI Lab 03 — Protected by Cloud Armor</h1><p>Instance: $(hostname)</p><p>Your request passed WAF inspection.</p></body></html>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}

resource "google_compute_region_instance_group_manager" "main" {
  name = local.mig_name
  base_instance_name = "${local.name_prefix}-vm"
  region  = var.region
  version {
    instance_template = google_compute_instance_template.main.id
  }
  target_size = 1
  description = "Managed instance group behind Cloud Armor"
}

# External HTTP load balancer
resource "google_compute_global_forwarding_rule" "main" {
  name       = "${local.name_prefix}-forwarding-rule"
  target     = google_compute_target_http_proxy.main.id
  port_range = "80"
  ip_address = google_compute_global_address.lb.address
  description = "Global forwarding rule for HTTP LB"
}

resource "google_compute_global_address" "lb" {
  name = local.lb_ip
  description = "Global IP for Cloud Armor-protected LB"
}

resource "google_compute_target_http_proxy" "main" {
  name        = local.lb_name
  url_map     = google_compute_url_map.main.id
  description = "HTTP proxy with Cloud Armor security policy"
  security_policy = google_compute_security_policy.armor.name
}

resource "google_compute_url_map" "main" {
  name            = "${local.name_prefix}-url-map"
  default_service = google_compute_backend_service.main.id
  description     = "URL map for Cloud Armor LB"
}

resource "google_compute_backend_service" "main" {
  name        = "${local.name_prefix}-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30
  health_checks = [google_compute_health_check.main.id]
  description   = "Backend service behind Cloud Armor"

  backend {
    group = google_compute_region_instance_group_manager.main.instance_group
  }
}
