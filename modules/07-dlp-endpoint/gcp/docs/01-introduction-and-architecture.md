# SDCI Lab 07 — GCP: Introduction & Architecture

## Objective

Deploy a DLP pipeline on GCP using Cloud DLP to inspect, classify, and de-identify sensitive data — mapping to **SDCI 300-745 objective 7.0**.

## DLP Pipeline

### 1. Data Storage — GCS Bucket

Sample sensitive data is stored in a GCS bucket as CSV and JSON files containing fake:

- Credit card numbers (e.g., `4111-1111-1111-1111`)
- Social Security numbers (e.g., `123-45-6789`)
- Email addresses (e.g., `alice@example.com`)
- Phone numbers (e.g., `555-0101`)
- Passwords and API keys

These are synthetic datasets — no real PII is used.

### 2. Inspection — DLP Inspect Template

The inspect template defines what to look for using Google's built-in infoType detectors:

| InfoType | Detects |
|----------|---------|
| `CREDIT_CARD_NUMBER` | Visa, MC, Amex, Discover |
| `US_SOCIAL_SECURITY_NUMBER` | SSN format (XXX-XX-XXXX) |
| `EMAIL_ADDRESS` | Standard email format |
| `PHONE_NUMBER` | US phone numbers |
| `PASSWORD` | Password-like strings |

A custom infoType `API_KEY` uses a dictionary of common key prefixes.

### 3. De-identification — De-identify Template

The de-identify template defines how to redact each infoType:

| InfoType | Transformation |
|----------|---------------|
| Credit card | Replace with `[CREDIT_CARD_NUMBER]` |
| SSN | Replace with `[REDACTED-SSN]` |
| Email | Replace with `[EMAIL_ADDRESS]` |

### 4. Automation — Job Trigger

The job trigger runs weekly on the entire bucket, writing findings to BigQuery for analysis.

## Architecture

```
Sample PII (CSV/JSON)
        │
        ▼
┌───────────────┐     ┌──────────────────┐
│   GCS Bucket  │────▶│ DLP Inspect Job  │
└───────────────┘     └────────┬─────────┘
                               │
                    ┌──────────▼──────────┐
                    │ Finding Results      │
                    │ (BigQuery Dataset)   │
                    └─────────────────────┘
```

## References

- [Cloud DLP Overview](https://cloud.google.com/dlp/docs/)
- [InfoType Detectors](https://cloud.google.com/dlp/docs/infotypes-reference)
