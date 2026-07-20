# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# providers.tf
#
# The provider is configured with user-supplied project, region, and zone.
# We intentionally do NOT hardcode these — each learner brings their own
# GCP project, so these are input variables.
#
# User impersonation / application default credentials are used (ADC) so no
# service account key file is needed on disk. This avoids secret sprawl.
# ------------------------------------------------------------------------------
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
