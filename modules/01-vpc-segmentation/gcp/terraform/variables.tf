# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# variables.tf
#
# Every input variable has:
#   - description: explains what this is and why it matters
#   - type: strict typing prevents misconfiguration
#   - default: sensible defaults where possible
#   - validation: catches bad input before Terraform tries to deploy
#
# OPINION: Over-engineering variables now prevents support questions later.
# ------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID where resources will be created. Find this in the GCP Console Project Dashboard."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "GCP region for all regional resources. Choose the closest region to reduce latency (e.g., us-central1, europe-west1)."
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1", "europe-west1", "europe-west4", "asia-southeast1", "asia-east1"], var.region)
    error_message = "Region must be a valid GCP region. Common training regions: us-central1, us-east1, europe-west1."
  }
}

variable "zone" {
  description = "GCP zone within the chosen region (e.g., us-central1-a). Used for compute instances."
  type        = string
  default     = "us-central1-a"

  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+-[a-z]$", var.zone))
    error_message = "Zone must be a valid GCP zone format (e.g., us-central1-a)."
  }
}

variable "creator" {
  description = "Your email or username. Used for cost tracking and resource attribution via the Creator tag."
  type        = string

  validation {
    condition     = length(var.creator) > 0
    error_message = "Creator must not be empty. Use your email or GitHub username."
  }
}

variable "destroy_after" {
  description = "Date by which resources should be destroyed, in YYYY-MM-DD format. This is a safety net tag, not an automated kill switch."
  type        = string
  default     = "2026-08-20"

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}$", var.destroy_after))
    error_message = "Must be a valid date in YYYY-MM-DD format."
  }
}

variable "enable_bastion" {
  description = "Whether to deploy a f1-micro bastion host. The bastion is free tier eligible (one per billing account). Set to false if you already have a bastion or prefer IAP tunnel."
  type        = bool
  default     = true
}

variable "enable_nat" {
  description = "Whether to deploy Cloud NAT for private instance egress. Cloud NAT costs ~$0.04/day. Set to false only if you don't need outbound internet from private instances."
  type        = bool
  default     = true
}

variable "ip_ranges" {
  description = "CIDR ranges for the three-tier subnets. Changing these requires destroying and recreating the subnets."
  type = object({
    access        = string
    distribution  = string
    core          = string
  })
  default = {
    access        = "10.0.1.0/24"
    distribution  = "10.0.2.0/24"
    core          = "10.0.3.0/24"
  }

  validation {
    condition     = alltrue([
      can(cidrhost(var.ip_ranges.access, 0)),
      can(cidrhost(var.ip_ranges.distribution, 0)),
      can(cidrhost(var.ip_ranges.core, 0)),
    ])
    error_message = "All IP ranges must be valid CIDR notation (e.g., 10.0.1.0/24)."
  }
}

variable "module_name" {
  description = "Module identifier for tagging. Override only if you rename the module."
  type        = string
  default     = "01-vpc-segmentation"
}
