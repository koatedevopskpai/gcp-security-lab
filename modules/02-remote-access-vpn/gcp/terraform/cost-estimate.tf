resource "null_resource" "cost_estimate" {
  triggers = {}

  provisioner "local-exec" {
    command = <<-EOT
      Write-Host @"
      ╔══════════════════════════════════════════════════════════════╗
      ║  COST ESTIMATE — SDCI Lab 02: Remote Access VPN (GCP)      ║
      ╠══════════════════════════════════════════════════════════════╣
      ║ Resource                       Qty    Rate/Day    Free Tier ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║ Hub VPC + subnets              1     $0.00       Yes       ║
      ║ On-prem VPC + subnets          1     $0.00       Yes       ║
      ║ Cloud Routers (2)              2     $0.00       Yes       ║
      ║ HA VPN Gateway                 1     $0.00       Yes       ║
      ║ VPN Tunnel                     1     $0.00       Yes*      ║
      ║ f1-micro instances (2)         2     $0.00       Yes       ║
      ║ Firewall rules                 6     $0.00       Yes       ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║  TOTAL                          -     $0.00                 ║
      ║                                                              ║
      ║  * 1 VPN tunnel free per region. Additional tunnels:         ║
      ║    ~$0.05/hr ($1.20/day). Production should use 2 for HA.   ║
      ║                                                              ║
      ║  Daily budget cap: $1.00 — you are at $0.00 with 1 tunnel.  ║
      ╚══════════════════════════════════════════════════════════════╝
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}
