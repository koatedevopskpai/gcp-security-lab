# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# tags.tf
#
# MANDATORY TAGGING ENFORCEMENT
#
# Every resource in this module MUST carry these tags. The local.mandatory_tags
# map is merged into every resource that supports labels.
#
# WHY THIS MATTERS:
# 1. Cost tracking — GCP Billing exports can group by label. Filtering on
#    CostCenter=SDCI-Lab gives you the complete cost of all lab activity.
# 2. Resource discovery — Module=01-vpc-segmentation identifies all resources
#    belonging to this specific lab.
# 3. Accountability — Creator and DestroyAfter provide a safety net for knowing
#    who deployed what and when it should be torn down.
#
# OPINION: Tags are not optional. If a resource doesn't support labels in GCP,
# we document it in the resource comments. For Module 01, all resources support
# labels except Cloud Router (we use description instead).
# ------------------------------------------------------------------------------
locals {
  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "gcp"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }
}

# Allow users to pass additional tags via a variable.
# These are merged in locals.tf where mandatory_tags always take precedence.
variable "extra_tags" {
  description = "Optional additional labels to apply to all resources. Useful for adding cost center overrides or environment-specific tags."
  type        = map(string)
  default     = {}
}
