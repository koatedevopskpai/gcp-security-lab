resource "null_resource" "cost_estimate" {
  provisioner "local-exec" {
    command = <<-EOT
      Write-Host @"
      ╔══════════════════════════════════════════════════════════════╗
      ║  COST ESTIMATE — SDCI Lab 03: NGFW & IDS/IPS (GCP)         ║
      ╠══════════════════════════════════════════════════════════════╣
      ║ Resource                       Qty    Rate/Day    Free Tier ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║ VPC + subnets (2)              1     $0.00       Yes       ║
      ║ Firewall rules (5)             5     $0.00       Yes       ║
      ║ Cloud Armor policy             1     $0.00       Yes*      ║
      ║ Cloud IDS endpoint             1     $0.00       Trial**   ║
      ║ HTTP Load Balancer             1     $0.60       No  ***   ║
      ║ f1-micro instance              1     $0.00       Yes       ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║  TOTAL                          -     $0.60                 ║
      ║                                                              ║
      ║  * Cloud Armor: 5 rules free. Additional: $0.25/rule/month. ║
      ║  ** Cloud IDS: 30-day free trial. After: $0.35/hr.          ║
      ║  *** HTTP LB: ~$0.025/hr ($0.60/day if left running).       ║
      ║                                                              ║
      ║  Daily budget cap: $1.00. 2-hr session = ~$0.05.            ║
      ╚══════════════════════════════════════════════════════════════╝
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}
