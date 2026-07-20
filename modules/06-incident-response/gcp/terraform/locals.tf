locals {
  zone = var.zone != "" ? var.zone : "${var.region}-a"
  name_prefix = "sdci-06-gcp"
  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "gcp"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }
  labels = merge(var.extra_tags, local.mandatory_tags)

  vpc_name        = "${local.name_prefix}-vpc"
  subnet_name     = "${local.name_prefix}-snet"
  router_name     = "${local.name_prefix}-router"
  nat_name        = "${local.name_prefix}-nat"
  vm_clean        = "${local.name_prefix}-vm-clean"
  vm_quarantined  = "${local.name_prefix}-vm-quarantined"
}
