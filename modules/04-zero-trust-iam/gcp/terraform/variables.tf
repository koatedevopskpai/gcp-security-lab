variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone (defaults to region-a)."
  type        = string
  default     = ""
}

variable "creator" {
  description = "Your email for cost tracking."
  type        = string
}

variable "destroy_after" {
  type    = string
  default = "2026-08-20"
}

variable "module_name" {
  type    = string
  default = "04-zero-trust-iam"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
