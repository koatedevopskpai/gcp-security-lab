# SDCI Lab 06 — GCP: Introduction & Architecture

## Objective

Implement an incident response quarantine mechanism on GCP using VPC firewall tags — mapping directly to **SDCI 300-745 exam objective 6.0**.

## Incident Response Framework

| Phase | Action | GCP Implementation |
|-------|--------|-------------------|
| Detect | Identify compromised VM | VPC Flow Logs, Cloud Logging alerts |
| Contain | Isolate VM from network | Apply `quarantine` firewall tag |
| Investigate | Access VM safely | IAP TCP forwarding (responder jump host) |
| Remediate | Fix or rebuild | Patch, restore from snapshot, redeploy |
| Recover | Restore network access | Remove `quarantine` tag |

## Quarantine Mechanism

GCP firewall rules use **priority-based evaluation**. Lower numbers have higher priority.

| Priority | Rule | Target Tag | Effect |
|----------|------|-----------|--------|
| 900 | Deny all ingress | `quarantine` | **Blocks ALL traffic** to tagged VMs |
| 1000 | Allow SSH (tcp:22) | `ssh-allowed` | Permits SSH during normal operation |
| 1000 | Allow internal | `internal-allowed` | Permits VPC-internal traffic |

When a VM has the `quarantine` tag, the deny-all rule at priority 900 **overrides** the allow rules at priority 1000. The VM becomes invisible on the network.

## Architecture

```
                          ┌──────────────────────────────────┐
                          │          GCP VPC                 │
                          │                                  │
                          │  Firewall Rules:                 │
                          │  P900  deny all [quarantine]     │
                          │  P1000 allow ssh [ssh-allowed]   │
                          │  P1000 allow int [internal]      │
                          │                                  │
                          │  ┌────────────────────────┐     │
                          │  │ vm-clean                │     │
                          │  │ tags: ssh-allowed       │     │
                          │  │ SSH: ✅ Accessible      │     │
                          │  └────────────────────────┘     │
                          │                                  │
                          │  ┌────────────────────────┐     │
                          │  │ vm-quarantined          │     │
                          │  │ tags: quarantine        │     │
                          │  │ SSH: ❌ Blocked (P900)  │     │
                          │  └────────────────────────┘     │
                          │                                  │
                          │  ┌────────────────────────┐     │
                          │  │ vm-clean (AFTER)        │     │
                          │  │ tags: +quarantine       │     │
                          │  │ SSH: ❌ Blocked (P900)  │     │
                          │  └────────────────────────┘     │
                          └──────────────────────────────────┘
```

## Automation

The included script `scripts/quarantine.ps1` wraps the `gcloud compute instances add-tags/remove-tags` command. In production, this would be triggered by a Cloud Function responding to a Security Command Center finding.

## Key Takeaway

Firewall tags in GCP are the fastest way to quarantine a VM. No new rules, no reconfiguration — just add a tag. The deny-all rule already exists; applying the tag activates it.

## References

- [VPC Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)
- [Incident Response Best Practices](https://cloud.google.com/architecture/incident-response-best-practices)
