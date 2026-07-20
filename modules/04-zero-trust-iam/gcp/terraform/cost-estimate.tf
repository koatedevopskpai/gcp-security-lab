# ==============================================================================
# Cost estimate — SDCI Lab 04 (GCP)
#
# RESOURCE                     ESTIMATED DAILY COST    NOTES
# ---------------------------  ----------------------  ----------------------------
# VPC + Subnet                 $0.00                  Free
# Firewall Rule                $0.00                  Free
# Cloud NAT                    ~$0.04/day             Data processing charge
# Cloud Router                 $0.00                  Included with NAT
# f1-micro VM                  $0.00                  Free tier eligible
# Boot disk 10 GB pd-standard  ~$0.00                 $0.04/GB/mo
# Service Account              $0.00                  Free
# Custom IAM Role              $0.00                  Free
# IAP TCP Forwarding           $0.00                  Free for SSH/RDP
# GCS Bucket (STANDARD)        ~$0.00                 $0.020/GB/mo minimal
# ---------------------------------------------------------------
# TOTAL (best case)            ~$0.00/day             Free tier covers everything
# TOTAL (worst case)           ~$0.04/day             No free tier, just NAT
# ==============================================================================
