# Module 01: VPC Segmentation — Introduction & Architecture

## What You'll Learn

This module aligns to the **Design Case Study Activity 1** from the Cisco SDCI 300-745 training materials — migrating a flat Layer 2 network to a layered, segmented design. You will:

1. Understand how the Cisco three-tier model (Access/Distribution/Core) maps to GCP
2. Deploy a VPC with three subnets (access, distribution, core)
3. Enforce zone-based firewall rules that simulate ACLs and micro-segmentation
4. Configure Cloud NAT for private instance egress
5. Verify lateral movement prevention between zones

## Cisco → GCP Mapping

| Cisco Concept | GCP Implementation | Why This Mapping |
|--------------|-------------------|-----------------|
| Access Layer (end-user ports) | `access` subnet (10.0.1.0/24) | End-user devices and bastion host connect here. Firewall tags differentiate user vs. IoT traffic within the same subnet. |
| Distribution Layer (routing, ACLs) | Firewall rules at subnet boundary + `distribution` subnet (10.0.2.0/24) | In GCP, the firewall is distributed across the VPC. We simulate the distribution layer's policy enforcement by placing restrictive rules at this boundary. |
| Core Layer (backbone) | `core` subnet (10.0.3.0/24) | Backend services and NAT egress live here. Traffic to this subnet is tightly controlled. |
| VLANs / 802.1Q tagging | Firewall `target_tags` and `source_tags` | GCP doesn't use VLANs. Tags act as the equivalent — an instance with tag "access-tier" gets different firewall treatment than one with tag "core-tier". |
| ACLs (Access Control Lists) | Firewall rules with source_ranges / target_tags | GCP firewall rules are stateful (unlike stateless ACLs). This is actually better — we get the policy enforcement of ACLs with the convenience of stateful inspection. |
| Micro-segmentation (IoT/OT isolation) | Tag-based firewall rules | Two instances in the same subnet can have different firewall rules based on their tags. This is micro-segmentation without VLANs. |

## Traffic Flow Diagram

```
                         Internet
                            │
                      [Cloud NAT]
                            │
                    ┌───────┴───────┐
                    │  Core Subnet  │
                    │  10.0.3.0/24  │
                    │  (backend)    │
                    └───────┬───────┘
                            │
                    ┌───────┴───────┐
                    │Distribution   │
                    │  Subnet       │  ← Firewall rule boundary
                    │  10.0.2.0/24  │
                    │  (policy)     │
                    └───────┬───────┘
                            │
                    ┌───────┴───────┐
                    │  Access Subnet│
                    │  10.0.1.0/24  │
                    │  (endpoints)  │
                    └───────┬───────┘
                            │
                      [Bastion Host]
                            │
                      [End Users]
```

## Firewall Rule Strategy

| Priority | Rule | Action | Purpose |
|----------|------|--------|---------|
| 1000 | Deny All Ingress | Deny | Default-deny (Zero Trust) |
| 1001 | Allow IAP SSH | Allow | Administrative access via IAP |
| 1002 | Allow Internal | Allow | Cross-tier communication on standard ports |
| 1003 | Allow Bastion SSH | Allow | Bastion → distribution/core SSH |
| 1004 | Deny Access to Core | Deny | Lateral movement prevention |
| 65535 | Allow All Egress | Allow | Outbound internet (lab convenience) |

## Why This Matters for SDCI 300-745

The exam tests your understanding of:
- **Network segmentation** — Why flat networks are dangerous and how to design layered ones
- **ACL enforcement** — Where and how to apply access control policies
- **Lateral movement prevention** — The security benefit of isolating zones
- **Phased migration** — How to transition from flat to segmented without downtime

By doing this lab, you'll see these concepts in action and understand how they apply to both on-premises (Cisco) and cloud (GCP) environments.
