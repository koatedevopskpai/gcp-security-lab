# SDCI Lab 03 — NGFW, IDS/IPS & Zone-Based Firewalls (GCP)

**SDCI 300-745 Domain**: Network security controls, WAF, IDS/IPS

## Overview

Deploy a Cloud Armor WAF policy protecting an HTTP load balancer. Cloud Armor blocks SQL injection, XSS, and protocol attacks at Layer 7. Zone-based firewall rules enforce web→app segmentation.

## Cost

HTTP LB: ~$0.025/hr ($0.60/day). Cloud Armor: free (5 rules). Cloud IDS: 30-day free trial.
