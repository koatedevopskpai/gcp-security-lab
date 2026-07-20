locals {
  name_prefix = "sdci-02-gcp"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "gcp"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  tags = merge(var.extra_tags, local.mandatory_tags)

  # Hub VPC (corporate network)
  hub_vpc_name      = "${local.name_prefix}-hub-vpc"
  hub_subnet_name   = "${local.name_prefix}-hub-snet"
  hub_subnet_cidr   = "10.1.0.0/24"
  hub_router_name   = "${local.name_prefix}-hub-router"
  hub_gw_name       = "${local.name_prefix}-hub-vpngw"

  # On-prem VPC (simulated remote site)
  onprem_vpc_name    = "${local.name_prefix}-onprem-vpc"
  onprem_subnet_name = "${local.name_prefix}-onprem-snet"
  onprem_subnet_cidr = "10.2.0.0/24"
  onprem_router_name = "${local.name_prefix}-onprem-router"
  onprem_gw_name     = "${local.name_prefix}-onprem-extgw"

  # VPN tunnels
  tunnel_name = "${local.name_prefix}-tunnel"

  # Test instances
  hub_workload_name    = "${local.name_prefix}-hub-vm"
  onprem_workload_name = "${local.name_prefix}-onprem-vm"
}
