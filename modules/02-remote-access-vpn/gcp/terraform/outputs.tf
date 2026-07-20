output "vpn_tunnel_name" {
  description = "Name of the VPN tunnel."
  value       = google_compute_vpn_tunnel.main.name
}

output "hub_vm_name" {
  description = "Name of the hub workload VM."
  value       = google_compute_instance.hub_workload.name
}

output "onprem_vm_name" {
  description = "Name of the on-prem workload VM."
  value       = google_compute_instance.onprem_workload.name
}

output "vpn_shared_secret" {
  description = "IPsec pre-shared key for the VPN tunnel."
  value       = random_id.vpn_psk.hex
  sensitive   = true
}

output "verify_vpn_connectivity" {
  description = "Commands to verify VPN connectivity between hub and on-prem."
  value = <<-EOT
    # Step 1: SSH into hub VM
    gcloud compute ssh ${local.hub_workload_name} --tunnel-through-iap --zone=${var.zone}

    # Step 2: From hub VM, ping the on-prem VM's private IP
    # (Get the private IP from the on-prem VM)
    HUB_IP=$(gcloud compute instances describe ${local.hub_workload_name} \
      --zone=${var.zone} --format='get(networkInterfaces[0].networkIP)')
    ONPREM_IP=$(gcloud compute instances describe ${local.onprem_workload_name} \
      --zone=${var.zone} --format='get(networkInterfaces[0].networkIP)')
    echo "Hub IP: $HUB_IP, On-prem IP: $ONPREM_IP"
    ping -c 4 $ONPREM_IP

    # Step 3: SSH into on-prem VM
    gcloud compute ssh ${local.onprem_workload_name} --tunnel-through-iap --zone=${var.zone}

    # Step 4: From on-prem VM, ping the hub VM
    ping -c 4 $HUB_IP

    # Expected result: Both pings succeed — BGP routes exchanged over VPN.
    # The hub VPC (10.1.0.0/24) and on-prem VPC (10.2.0.0/24) are connected
    # via the IPsec tunnel, simulating a secure site-to-site VPN.
  EOT
}

output "cost_warning" {
  value = <<-EOT
    ╔══════════════════════════════════════════════════════╗
    ║  COST WARNING                                        ║
    ╠══════════════════════════════════════════════════════╣
    ║ 1 Cloud VPN tunnel: FREE (1 per region)             ║
    ║ 2 f1-micro instances: FREE (free tier)              ║
    ║ VPCs, subnets, routers: FREE                        ║
    ║                                                      ║
    ║ Total: $0.00/day (within free tier)                  ║
    ╚══════════════════════════════════════════════════════╝
  EOT
}
