# Module 02: Remote Access VPN — Architecture (GCP)

## Scenario

A mid-sized enterprise has a corporate headquarters (hub) and a remote branch office (on-prem). They need secure, encrypted connectivity between the two sites over the public internet. This is the **Internet Edge** scenario from SDCI 300-745.

## GCP Solution: HA VPN Gateway + Cloud Router (BGP)

GCP's HA VPN Gateway provides 99.99% SLA IPsec VPN connectivity. Cloud Router uses BGP to dynamically exchange routes between the two sites.

### Architecture

```
┌──────────────────┐          IPsec Tunnel          ┌──────────────────┐
│   Hub VPC        │◄══════════════════════════════►│  On-Prem VPC     │
│   10.1.0.0/24    │                                 │  10.2.0.0/24     │
│                  │  BGP ASN 64514                  │                  │
│  ┌──────────┐    │   169.254.1.1/30                │  ┌──────────┐    │
│  │Hub Router│────┤          ┌──────────┐           ├──│OnPrem Rtr│    │
│  └──────────┘    │          │VPN Tunnel│           │  └──────────┘    │
│  ┌──────────┐    │          └──────────┘           │  ┌──────────┐    │
│  │Hub VM    │    │                                 │  │OnPrem VM │    │
│  └──────────┘    │                                 │  └──────────┘    │
└──────────────────┘                                 └──────────────────┘
```

### Key Components

| Component | GCP Resource | Purpose |
|-----------|-------------|---------|
| Hub VPC | `google_compute_network` | Corporate network |
| On-prem VPC | `google_compute_network` | Remote branch simulation |
| Hub VPN Gateway | `google_compute_ha_vpn_gateway` | Hub-side VPN termination |
| External VPN Gateway | `google_compute_external_vpn_gateway` | Simulates remote VPN device |
| Cloud Routers | `google_compute_router` | BGP route exchange |
| VPN Tunnel | `google_compute_vpn_tunnel` | Encrypted IPsec tunnel |
| BGP Sessions | `google_compute_router_peer` | Dynamic route advertisement |

### Traffic Flow

1. Hub VM (10.1.0.2) sends packet to OnPrem VM (10.2.0.2)
2. Packet hits hub VPC → routed to VPN gateway via BGP-learned route
3. VPN gateway encrypts and sends over IPsec tunnel
4. On-prem VPN gateway decrypts → routes to OnPrem VM
5. Return path follows same pattern in reverse

### BGP Route Exchange

- Hub Cloud Router (ASN 64514) advertises 10.1.0.0/24
- On-prem Cloud Router (ASN 64515) advertises 10.2.0.0/24
- Both sides learn routes dynamically (no static routes needed)

### SDCI 300-745 Connection

This directly maps to the **Internet Edge** layer discussion:
- The VPN tunnel provides secure encrypted connectivity across the public internet
- The Internet Edge is where VPNs terminate, forming the boundary between corporate and external networks
- This replaces the traditional leased-line model with encrypted site-to-site VPN
