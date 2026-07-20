# Module Scaffold Template

Use this template when creating new modules to ensure consistency across all 8 modules.

## Directory Structure

```
modules/{NN}-{module-name}/
└── gcp/
    ├── terraform/
    │   ├── versions.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── locals.tf
    │   ├── tags.tf
    │   ├── cost-estimate.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── backend.tf (optional, for remote state)
    ├── docs/
    │   ├── 01-introduction-and-architecture.md
    │   ├── 02-free-tier-cost-analysis.md
    │   └── 03-guided-walkthrough.md
    ├── cleanup.ps1
    └── README.md
```

## Terraform Design Rules

1. **`versions.tf`** — Pin provider to major.minor, not patch:
   ```hcl
   required_providers {
     google = {
       source  = "hashicorp/google"
       version = "~> 5.0"
     }
   }
   ```

2. **`providers.tf`** — One provider block with configurable project/region/zone.

3. **`variables.tf`** — Every variable has `description`, `type`, `default`, and `validation` block.

4. **`locals.tf`** — All computed values, naming conventions, merged tag maps.

5. **`tags.tf`** — Mandatory tag map consumed by every resource.

6. **`cost-estimate.tf`** — Local cost projection printed during `plan`.

7. **`main.tf`** — All core resources. Split into `vpc.tf`, `firewall.tf`, etc. only when exceeding 100 lines per file.

8. **`outputs.tf`** — Every module outputs connection strings, IPs, and verification commands.

## Tag Enforcement

```hcl
locals {
  mandatory_tags = {
    CostCenter    = "SDCI-Lab"
    Environment   = "Training"
    Module        = var.module_name
    Cloud         = "gcp"
    Creator       = var.creator
    DestroyAfter  = var.destroy_after
  }
}
```

## Commit Messages

Use conventional commits:
- `feat: add {resource} for {purpose}`
- `docs: add cost analysis and walkthrough for module {NN}`
- `chore: update provider versions`
