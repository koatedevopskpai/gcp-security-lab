locals {
  name_prefix = "sdci-03-gcp"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "gcp"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  tags = merge(var.extra_tags, local.mandatory_tags)

  vpc_name     = "${local.name_prefix}-vpc"
  snet_web     = "${local.name_prefix}-snet-web"
  snet_app     = "${local.name_prefix}-snet-app"

  armor_policy = "${local.name_prefix}-armor-policy"

  ids_name     = "${local.name_prefix}-ids"

  mig_name     = "${local.name_prefix}-mig"
  instance_template = "${local.name_prefix}-template"

  lb_name      = "${local.name_prefix}-lb"
  lb_ip        = "${local.name_prefix}-lb-ip"
  health_check = "${local.name_prefix}-hc"
}
