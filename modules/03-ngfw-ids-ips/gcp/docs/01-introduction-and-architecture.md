# Module 03: NGFW, IDS/IPS & Zone-Based Firewalls (GCP)

## Scenario

A web application needs protection against OWASP Top 10 attacks (SQL injection, XSS, LFI) and network-level threats. This is the **NGFW + IDS/IPS** scenario from SDCI 300-745.

## Architecture

```
Internet → Cloud Armor (WAF) → HTTP LB → Web subnet → App subnet
           Layer 7 inspection       │              │
                                    │  Firewall    │
                                    │  rules:      │
                                    │  web→app:80  │
                                    │              │
                                    └── Cloud IDS (traffic monitoring)
```

### Three Security Layers

| Layer | Service | Function | SDCI 300-745 Equivalent |
|-------|---------|----------|------------------------|
| Layer 7 | Cloud Armor | WAF — blocks SQLi, XSS, protocol attacks | Next-Generation Firewall |
| Layer 3-4 | Cloud IDS | Network threat detection | IDS/IPS at distribution layer |
| Layer 3-4 | VPC Firewall Rules | Zone-based segmentation | ACL enforcement |

### Cloud Armor WAF Rules

| Priority | Rule | Action | Protects Against |
|----------|------|--------|-----------------|
| 1000 | SQL Injection | Deny (403) | SQLi attacks |
| 1001 | Cross-Site Scripting | Deny (403) | XSS attacks |
| 1002 | Protocol Attack | Deny (403) | LFI, RFI, RCE |
| 2147483647 | Default Allow | Allow | Legitimate traffic |

### Zone-Based Firewall Rules

| Priority | Rule | Purpose |
|----------|------|---------|
| 1000 | Deny All Ingress | Default-deny (Zero Trust) |
| 1001 | Allow Health Checks | LB probe traffic |
| 1002 | Allow IAP SSH | Admin access |
| 1010 | Allow Web→App:80/8080 | Simulates distribution ACL |
| 1011 | Allow LB→Web:80 | LB to web tier |

### SDCI 300-745 Connection

The exam covers NGFW placement at the distribution layer. This lab demonstrates:
- **WAF** at the edge (Internet Edge layer) protecting against web attacks
- **Zone-based firewall rules** enforcing traffic boundaries between tiers
- **IDS** monitoring traffic for malicious patterns — the foundation for SIEM correlation (Module 05)
