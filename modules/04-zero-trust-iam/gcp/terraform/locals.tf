locals {
  zone = var.zone != "" ? var.zone : "${var.region}-a"

  name_prefix = "sdci-04-gcp"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "gcp"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  labels = merge(var.extra_tags, local.mandatory_tags)

  vpc_name       = "${local.name_prefix}-vpc"
  subnet_name    = "${local.name_prefix}-subnet"
  router_name    = "${local.name_prefix}-nat-router"
  nat_name       = "${local.name_prefix}-nat"
  vm_name        = "${local.name_prefix}-vm"
  sa_name        = "${local.name_prefix}-sa"
  bucket_name    = "${local.name_prefix}-bucket-${var.project_id}"
  custom_role_id = "${local.name_prefix}_custom_role"
}
