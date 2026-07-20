# ==============================================================================
# Cost estimate — SDCI Lab 05 (GCP)
#
# RESOURCE                     ESTIMATED DAILY COST    NOTES
# ---------------------------  ----------------------  ----------------------------
# VPC + Subnet                 $0.00                  Free
# VPC Flow Logs                ~$0.00                 $0.15/GB ingested; minimal (<1 GB)
# Firewall Rules               $0.00                  Free
# Cloud NAT                    ~$0.04/day             Minimum charge
# Cloud Router                 $0.00                  Free
# f1-micro VM                  $0.00                  Free tier eligible
# Boot disk 10 GB              ~$0.00                 $0.04/GB/mo
# Cloud Logging                $0.00                  Free tier: 50 GB/month
# Log-based Metric             $0.00                  Free
# Cloud Monitoring             $0.00                  Free tier: 15 metrics, 5 alert policies
# Alert Policy                 $0.00                  Free
# ---------------------------------------------------------------
# TOTAL                        ~$0.04/day
# ==============================================================================
