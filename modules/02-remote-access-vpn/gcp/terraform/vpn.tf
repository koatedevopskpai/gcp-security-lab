# ------------------------------------------------------------------------------
# SDCI Lab 02 — Remote Access VPN (GCP)
# vpn.tf
#
# ARCHITECTURE:
# We create TWO VPCs connected via Cloud VPN:
#   1. Hub VPC  (10.1.0.0/24)  — simulates the corporate network
#   2. On-prem VPC (10.2.0.0/24) — simulates a remote branch/office
#
# A HA VPN Gateway in the hub connects to an External VPN Gateway in the
# on-prem VPC via an IPsec tunnel. BGP (via Cloud Router) exchanges routes
# dynamically so both sides know how to reach each other.
#
# WHY HA VPN INSTEAD OF CLASSIC VPN:
# Classic VPN is deprecated. HA VPN provides 99.99% SLA, supports BGP, and
# is the recommended path forward. For this lab we use 1 tunnel (the free
# tier limit is 1 per region) and note that production should use 2.
#
# COST: 1 Cloud VPN tunnel is free per region. Additional tunnels cost
# ~$0.05/hour. This lab uses 1 tunnel — free.
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# HUB VPC — Corporate network
# --------------------------------------------------------------------------
resource "google_compute_network" "hub" {
  name                    = local.hub_vpc_name
  auto_create_subnetworks = false
  description             = "Hub VPC — corporate network for VPN lab"
}

resource "google_compute_subnetwork" "hub" {
  name          = local.hub_subnet_name
  ip_cidr_range = local.hub_subnet_cidr
  region        = var.region
  network       = google_compute_network.hub.id

  private_ip_google_access = true
  labels = local.tags
}

# --------------------------------------------------------------------------
# ON-PREM VPC — Remote site simulation
# --------------------------------------------------------------------------
resource "google_compute_network" "onprem" {
  name                    = local.onprem_vpc_name
  auto_create_subnetworks = false
  description             = "On-prem VPC — simulated remote branch"
}

resource "google_compute_subnetwork" "onprem" {
  name          = local.onprem_subnet_name
  ip_cidr_range = local.onprem_subnet_cidr
  region        = var.region
  network       = google_compute_network.onprem.id

  private_ip_google_access = true
  labels = local.tags
}

# --------------------------------------------------------------------------
# HUB CLOUD ROUTER — BGP speaker for the hub side
# --------------------------------------------------------------------------
resource "google_compute_router" "hub" {
  name    = local.hub_router_name
  region  = var.region
  network = google_compute_network.hub.id

  bgp {
    asn = 64514  # Private ASN for hub
  }

  description = "Hub Cloud Router with BGP ASN 64514"
}

# --------------------------------------------------------------------------
# ON-PREM CLOUD ROUTER — BGP speaker for the remote side
# --------------------------------------------------------------------------
resource "google_compute_router" "onprem" {
  name    = local.onprem_router_name
  region  = var.region
  network = google_compute_network.onprem.id

  bgp {
    asn = 64515  # Private ASN for on-prem
  }

  description = "On-prem Cloud Router with BGP ASN 64515"
}

# --------------------------------------------------------------------------
# HUB HA VPN GATEWAY
# An HA VPN gateway has 2 interfaces (one per zone) for redundancy.
# We create both interfaces but only use one tunnel for this lab.
# --------------------------------------------------------------------------
resource "google_compute_ha_vpn_gateway" "hub" {
  name    = local.hub_gw_name
  region  = var.region
  network = google_compute_network.hub.id

  description = "HA VPN Gateway — hub side"
  labels      = local.tags
}

# --------------------------------------------------------------------------
# ON-PREM EXTERNAL VPN GATEWAY
# Simulates a remote VPN device by exposing a static IP.
# In real life, this would be a physical firewall or router.
# --------------------------------------------------------------------------
resource "google_compute_external_vpn_gateway" "onprem" {
  name        = local.onprem_gw_name
  description = "External VPN Gateway — simulates on-premises VPN device"

  # We use the hub VPN gateway's first interface IP as the external peer.
  # This creates a self-referencing tunnel between hub and on-prem.
  # In production, this would be the public IP of your remote firewall.
  interface {
    id         = 0
    ip_address = google_compute_address.hub_vpn_ip.address
  }
}

# Static IP for the hub VPN gateway interface
resource "google_compute_address" "hub_vpn_ip" {
  name   = "${local.name_prefix}-hub-vpn-ip"
  region = var.region
}

resource "google_compute_address" "onprem_vpn_ip" {
  name   = "${local.name_prefix}-onprem-vpn-ip"
  region = var.region
}

# --------------------------------------------------------------------------
# VPN TUNNEL — IPsec tunnel between hub and on-prem
# GCP offers 1 free VPN tunnel per region. This lab uses 1 tunnel.
# For production HA, add a second tunnel targeting the other gateway
# interface with a different BGP session.
# --------------------------------------------------------------------------
resource "google_compute_vpn_tunnel" "main" {
  name = local.tunnel_name

  region      = var.region
  peer_ip     = google_compute_address.hub_vpn_ip.address
  shared_secret = random_id.vpn_psk.hex

  target_vpn_gateway = google_compute_ha_vpn_gateway.hub.id
  vpn_gateway        = google_compute_ha_vpn_gateway.hub.id
  vpn_gateway_interface = 0

  router = google_compute_router.hub.id

  description = "IPsec tunnel between hub and on-prem (HA VPN)"
  labels      = local.tags
}

# Pre-shared key for IPsec
resource "random_id" "vpn_psk" {
  byte_length = 16
}

# --------------------------------------------------------------------------
# BGP SESSION on hub side — advertises hub routes to on-prem
# --------------------------------------------------------------------------
resource "google_compute_router_interface" "hub_bgp" {
  name       = "${local.name_prefix}-hub-bgp-int"
  router     = google_compute_router.hub.name
  region     = var.region
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.main.name
}

resource "google_compute_router_peer" "hub_bgp" {
  name                      = "${local.name_prefix}-hub-bgp-peer"
  router                    = google_compute_router.hub.name
  region                    = var.region
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = 64515
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.hub_bgp.name
}

# --------------------------------------------------------------------------
# BGP SESSION on on-prem side — advertises on-prem routes to hub
# --------------------------------------------------------------------------
resource "google_compute_router_interface" "onprem_bgp" {
  name       = "${local.name_prefix}-onprem-bgp-int"
  router     = google_compute_router.onprem.name
  region     = var.region
  ip_range   = "169.254.1.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.main.name
}

resource "google_compute_router_peer" "onprem_bgp" {
  name                      = "${local.name_prefix}-onprem-bgp-peer"
  router                    = google_compute_router.onprem.name
  region                    = var.region
  peer_ip_address           = "169.254.1.1"
  peer_asn                  = 64514
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.onprem_bgp.name
}
