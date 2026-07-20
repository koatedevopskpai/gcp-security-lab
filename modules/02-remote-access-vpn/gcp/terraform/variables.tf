variable "project_id" {
  description = "GCP project ID."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, lowercase letters/numbers/hyphens."
  }
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone."
  type        = string
  default     = "us-central1-a"
}

variable "creator" {
  description = "Your email or username for cost tracking."
  type        = string
  validation {
    condition     = length(var.creator) > 0
    error_message = "Creator must not be empty."
  }
}

variable "destroy_after" {
  description = "Date by which resources should be destroyed (YYYY-MM-DD)."
  type        = string
  default     = "2026-08-20"
}

variable "module_name" {
  type    = string
  default = "02-remote-access-vpn"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
