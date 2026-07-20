# SDCI Lab 05 — GCP: Introduction & Architecture

## Objective

Deploy a complete SIEM monitoring pipeline on GCP — VPC Flow Log ingestion, log-based metric extraction, and Cloud Monitoring alerting — mapping directly to **SDCI 300-745 exam objective 5.0**.

## Monitoring Pipeline Architecture

### Ingestion Layer — VPC Flow Logs

Every subnet can optionally enable VPC Flow Logs, which capture:

- Source/destination IP and port
- Protocol
- Packets and bytes transferred
- Action (ACCEPT/DENY)

Flow logs are streamed to Cloud Logging automatically — no agents, no configuration beyond enabling on the subnet.

### Storage Layer — Cloud Logging

Cloud Logging stores all log entries with configurable retention (30 days default, extendable via log buckets). Logs are queryable via the Logs Explorer UI or API using the Logging query language.

### Analysis Layer — Log-Based Metrics

Log-based metrics extract numerical values from log content. In this lab, we create a metric called `sdci-05-gcp-ssh-attempts` that counts the number of VPC Flow Log entries where:

- Destination port = 22 (SSH)
- Protocol = 6 (TCP)
- Reporter = SRC (traffic originator)

Labels extract source IP, destination IP, and source port for drill-down.

### Alerting Layer — Cloud Monitoring Alert Policy

The alert policy fires when the SSH attempt count exceeds 10 in a 5-minute window. In production, this would trigger a notification channel (email, PagerDuty, Slack). For the lab, we leave notification channels empty and view the alert in the Monitoring console.

## Architecture Diagram

```
                          ┌──────────────────────────────────┐
                          │          GCP Project             │
                          │                                  │
                          │   External SSH attempt           │
                          │   (synthetic traffic)            │
                          │          │                       │
                          │          ▼                       │
                          │   ┌──────────────────┐          │
                          │   │  Public Subnet   │          │
                          │   │  10.0.1.0/24     │          │
                          │   │  VPC Flow Logs   │          │
                          │   │                  │          │
                          │   │ ┌──────────────┐ │          │
                          │   │ │ f1-micro VM  │ │          │
                          │   │ │ (SSH target) │ │          │
                          │   │ └──────────────┘ │          │
                          │   └────────┬─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │  Cloud Logging    │          │
                          │   │  (VPC Flow Logs)  │          │
                          │   └────────┬─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │  Log-Based Metric │          │
                          │   │  (SSH attempts)   │          │
                          │   └────────┬─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │  Alert Policy    │          │
                          │   │  (>10 SSH/5min)  │          │
                          │   └──────────────────┘          │
                          └──────────────────────────────────┘
```

## Key Resources

| Resource | Purpose |
|----------|---------|
| Subnet with `log_config` | Enables VPC Flow Logs |
| `google_logging_metric` | Defines metric from log filter |
| `google_monitoring_alert_policy` | Alert on metric threshold |

## References

- [VPC Flow Logs Documentation](https://cloud.google.com/vpc/docs/using-flow-logs)
- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [Log-Based Metrics](https://cloud.google.com/logging/docs/logs-based-metrics)
- [Cloud Monitoring Alerts](https://cloud.google.com/monitoring/alerts)
