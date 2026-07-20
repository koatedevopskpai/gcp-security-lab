# SDCI Lab 04 — GCP: Introduction & Architecture

## Objective

Implement Zero Trust principles on GCP using IAM, Identity-Aware Proxy (IAP), and Service Accounts — mapping directly to the **SDCI 300-745 exam objective 4.0**.

## Zero Trust Principles Applied

### 1. Never Trust, Always Verify

The VM has **no public IP**. There is no firewall rule allowing SSH from the internet. The only way to access the VM is through Identity-Aware Proxy (IAP), which authenticates the user and authorizes the connection before forwarding traffic.

### 2. Least Privilege

The VM runs under a Service Account with a **custom role** that contains only two permissions:
- `storage.objects.get` — download objects
- `storage.objects.list` — list bucket contents

If the VM is compromised, the attacker cannot create, delete, or modify any storage objects.

### 3. Workload Identity

Instead of static service account keys, the **Service Account is bound directly to the Compute Engine instance**. The VM authenticates as the service account using the instance metadata server — no keys to leak or rotate.

### 4. Continuous Validation

IAM Conditions enforce that the service account can only access objects **after the request reaches the resource**. Access is re-evaluated on every request.

## Architecture

```
                          ┌──────────────────────────────────┐
                          │          GCP Project             │
                          │                                  │
                          │   Developer's Machine            │
                          │   gcloud compute ssh --tunnel-   │
                          │   through-iap                    │
                          │          │                       │
                          │          ▼                       │
                          │   IAP TCP Forwarding             │
                          │   (authenticates + authorizes    │
                          │    the user via Google identity) │
                          │          │                       │
                          │          ▼                       │
                          │   ┌──────────────────┐          │
                          │   │  Private Subnet  │          │
                          │   │  10.0.1.0/24     │          │
                          │   │  No public IP    │          │
                          │   │                  │          │
                          │   │ ┌──────────────┐ │          │
                          │   │ │ f1-micro VM  │ │          │
                          │   │ │ SA attached  │ │          │
                          │   │ └──────┬───────┘ │          │
                          │   └────────┼─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │  GCS Bucket      │          │
                          │   │  (read-only by   │          │
                          │   │   custom role)   │          │
                          │   └──────────────────┘          │
                          │                                  │
                          │   Cloud NAT (outbound only)      │
                          └──────────────────────────────────┘
```

## Key IAM Resources

| Resource | Purpose |
|----------|---------|
| `google_service_account` | Workload identity for VM |
| `google_project_iam_custom_role` | Least-privilege role definition |
| `google_project_iam_member` | Binds SA to custom role at project level |
| `google_storage_bucket_iam_member` | Binds SA to bucket with IAM condition |
| `google_compute_instance.service_account` | Attaches SA to VM |

## Security Controls Checklist

| Control | Status | Notes |
|---------|--------|-------|
| No public IP on VM | ✅ | Private subnet only |
| SSH via IAP only | ✅ | Firewall allows 35.235.240.0/20 only |
| Custom least-privilege role | ✅ | 2 permissions only |
| Workload identity (no keys) | ✅ | SA bound to instance metadata |
| IAM condition on bucket | ✅ | Resource-name prefix check |
| OS Login enabled | ✅ | Metadata key `enable-oslogin=TRUE` |

## References

- [GCP IAM Overview](https://cloud.google.com/iam/docs/overview)
- [Identity-Aware Proxy](https://cloud.google.com/iap/docs/)
- [IAM Conditions](https://cloud.google.com/iam/docs/conditions-overview)
- [Service Accounts Best Practices](https://cloud.google.com/iam/docs/best-practices-for-using-service-accounts)
