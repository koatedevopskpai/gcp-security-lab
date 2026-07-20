# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# versions.tf
#
# WHY WE PIN PROVIDER VERSIONS:
# Terraform provider releases can introduce breaking changes or alter resource
# behavior silently. Pinning to a major.minor range (~> 5.0 means >= 5.0, < 6.0)
# ensures reproducibility across learner environments while allowing patch-level
# fixes. For production, pin to an exact version; for training, this range is
# the right balance.
# ------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.6, < 2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
