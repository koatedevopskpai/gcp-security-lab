# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# locals.tf
#
# Naming conventions and computed values live here. Keeping them in locals
# rather than inline in resources makes refactoring trivial.
#
# NAMING CONVENTION: sdci-{module}-{resource-type}-{suffix}
#   sdci = Security-DCI lab prefix (consistent across all clouds)
#   01   = module number
#   vpc  = resource type abbreviation
#   gcp  = cloud provider
#
# This convention makes resource discovery in the GCP Console immediate —
# you can filter by "sdci-01-gcp" and see everything belonging to this module.
# ------------------------------------------------------------------------------
locals {
  name_prefix = "sdci-01-gcp"

  # Merge user-provided tags with mandatory tags.
  # The merge() call ensures mandatory tags cannot be overridden by extra_tags.
  # If a learner passes extra_tags with the same key as a mandatory tag,
  # the mandatory tag wins. This is intentional — we enforce FinOps compliance.
  tags = merge(
    var.extra_tags,
    local.mandatory_tags
  )

  # All three tiers share the same VPC name but have distinct subnet names.
  # This is by design in GCP — subnets are regional, not hierarchical.
  vpc_name        = "${local.name_prefix}-vpc"
  subnet_access   = "${local.name_prefix}-subnet-access"
  subnet_dist     = "${local.name_prefix}-subnet-distribution"
  subnet_core     = "${local.name_prefix}-subnet-core"

  # Firewall rule names follow the convention:
  #   {vpc-name}-{direction}-{protocol/purpose}-{scope}
  fw_deny_all_ingress  = "${local.name_prefix}-fw-deny-all-ingress"
  fw_allow_iap_ssh     = "${local.name_prefix}-fw-allow-iap-ssh"
  fw_allow_internal    = "${local.name_prefix}-fw-allow-internal"
  fw_allow_bastion_ssh = "${local.name_prefix}-fw-allow-bastion-ssh"
  fw_deny_access_to_core = "${local.name_prefix}-fw-deny-access-to-core"
  fw_allow_egress       = "${local.name_prefix}-fw-allow-egress"

  router_name  = "${local.name_prefix}-router"
  nat_name     = "${local.name_prefix}-nat"

  bastion_name = "${local.name_prefix}-bastion"
  bastion_sa   = "${local.name_prefix}-bastion-sa"
}
