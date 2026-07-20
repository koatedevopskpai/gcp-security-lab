# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# bastion.tf
#
# BASTION HOST (JUMP BOX)
#
# A minimal f1-micro instance in the access subnet that serves as the
# administrative entry point to the segmented network. From the bastion,
# you can SSH into instances in the distribution and core subnets.
#
# DECISION: Bastion vs. IAP TCP Tunneling
# GCP's IAP TCP forwarding (https://cloud.google.com/iap/docs/using-tcp-forwarding)
# eliminates the need for a bastion entirely. We offer the bastion as an option
# because:
#   1. It mirrors the traditional enterprise pattern used in the Cisco curriculum
#   2. Some learners may not have IAP enabled on their project
#   3. It demonstrates bastion/ssh-agent patterns used in real enterprises
#
# COST: The f1-micro instance is free tier eligible (one per billing account).
# If you already have a free tier instance running, this will incur charges
# (~$5/month). Set enable_bastion = false in that case.
#
# SECURITY: The bastion has NO public IP by design. Access is via IAP TCP
# tunneling: gcloud compute ssh bastion --tunnel-through-iap
# ------------------------------------------------------------------------------

resource "google_service_account" "bastion" {
  count        = var.enable_bastion ? 1 : 0
  account_id   = local.bastion_sa
  display_name = "SDCI Lab 01 Bastion SA"
  description  = "Service account for the bastion host. Minimal permissions — only what's needed for SSH and instance metadata queries."
}

resource "google_compute_instance" "bastion" {
  count        = var.enable_bastion ? 1 : 0
  name         = local.bastion_name
  machine_type = "f1-micro"
  zone         = var.zone

  tags = ["bastion-tier", "access-tier"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.access.id

    # No public IP — all access is via IAP TCP forwarding.
    # This is more secure and avoids the cost of an ephemeral IP.
    access_config {
      # Empty block = no external IP. Leaving the block present but empty
      # means the instance is created without a NAT/public IP.
    }
  }

  service_account {
    email  = google_service_account.bastion[0].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
    cost-center    = "SDCI-Lab"
    module         = var.module_name
    creator        = var.creator
    destroy-after  = var.destroy_after
  }

  labels = local.tags

  description = "Bastion host for administrative access to segmented network"
}
