# GCP Security Lab — Architecture

## Design Philosophy

These labs translate enterprise network security concepts from Cisco SDCI 300-745 into idiomatic GCP implementations. The guiding principle is **conceptual parity, not literal parity** — the Access/Distribution/Core layer model maps to GCP's flat VPC hierarchy enhanced with firewall rules and tagging, not a literal three-tier topology.

## Cross-Module Architecture

```
[User Devices] ──> [Access Subnet] ──> [Firewall Rules] ──> [Distribution Subnet] ──> [Core Subnet] ──> [Internet/NAT]
                        │                     │                      │
                        │      [Cloud IDS]     │                      │
                        └───────┴──────────────┴──────────────────────┘
                                              │
                                     [Security Command Center]
                                              │
                                     [Chronicle / Cloud Logging]
```

## Module 01: VPC Segmentation Architecture

### Mapping: Cisco 3-Tier → GCP

| Cisco Layer | GCP Resource | Purpose |
|-------------|-------------|---------|
| Access Layer | `access` subnet (10.0.1.0/24) | End-user device connectivity, port security simulation via firewall tags |
| Distribution Layer | `distribution` subnet (10.0.2.0/24) | Inter-zone routing boundary, ACL enforcement via hierarchical firewall rules |
| Core Layer | `core` subnet (10.0.3.0/24) | High-speed backbone, NAT gateway placement |
| Micro-segmentation | Firewall rule `target_tags` + service accounts | Workload-level isolation (IoT/OT/user) without VLANs |

### Traffic Flow Logic

1. **User-to-internal**: Instance in `access` subnet can reach `distribution` subnet on allowed ports only (e.g., SSH from bastion)
2. **Zone isolation**: `access` subnet cannot initiate traffic to `core` subnet (blocked by firewall rule)
3. **Internet egress**: Instances in private subnets egress through Cloud NAT (no public IPs)
4. **Lateral movement prevention**: Firewall tags enforce that tagged IoT instances cannot talk to tagged User instances, even within the same subnet

### Key Decision: Why Not a Literal Three-Tier VPC?

GCP VPCs are global and flat — subnets are regional, not hierarchical. We simulate the distribution layer using **hierarchical firewall policies** applied at the VPC level with `target_tags` and `source_tags`, which provides the same policy enforcement boundary without forcing a physical topology that doesn't exist in GCP.

## Tagging Standards

Every resource in every module carries these mandatory tags:

| Tag Key | Value | Purpose |
|---------|-------|---------|
| `CostCenter` | `SDCI-Lab` | Group all lab costs in billing exports |
| `Environment` | `Training` | Distinguish lab from production |
| `Module` | e.g. `01-vpc-segmentation` | Per-module cost tracking |
| `Cloud` | `gcp` | Cross-cloud cost comparison |
| `Creator` | (user input) | Who deployed this |
| `DestroyAfter` | `2026-08-20` | Safety net date |

## State Management

Labs use **local Terraform state** by design. Rationale:
- Learners run in personal accounts without shared backends
- Simplicity for training: no GCS bucket setup required
- A `terraform destroy` reliably cleans up without state coordination

> For production deployments, migrate to a GCS backend with locking. See `shared/templates/` for the backend config template.
