locals {
  name_prefix = "sdci-07-gcp"
  mandatory_tags = {
    CostCenter = "SDCI-Lab"; Environment = "Training"; Module = var.module_name; Cloud = "gcp"
    Creator = var.creator; DestroyAfter = var.destroy_after
  }
  labels = merge(var.extra_tags, local.mandatory_tags)
  bucket_name = "${local.name_prefix}-data-${var.project_id}"
}
