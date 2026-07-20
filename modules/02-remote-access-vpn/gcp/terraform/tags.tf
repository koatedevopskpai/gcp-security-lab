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

variable "extra_tags" {
  description = "Optional additional labels."
  type        = map(string)
  default     = {}
}
