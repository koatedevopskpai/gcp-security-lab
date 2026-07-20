# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (GCP)
# outputs.tf
#
# Every module outputs connection strings, IPs, and verification commands.
# This makes it easy to copy-paste the next step after terraform apply.
#
# OPINION: Outputs are documentation. Each one includes a description that
# explains how to use it, not just what it is.
# ------------------------------------------------------------------------------

output "project_id" {
  description = "GCP project ID where resources were deployed."
  value       = var.project_id
}

output "vpc_name" {
  description = "Name of the created VPC. Use this when referencing the VPC in gcloud commands."
  value       = google_compute_network.main.name
}

output "subnet_access_cidr" {
  description = "CIDR range of the access subnet (end-user devices)."
  value       = var.ip_ranges.access
}

output "subnet_distribution_cidr" {
  description = "CIDR range of the distribution subnet (policy enforcement)."
  value       = var.ip_ranges.distribution
}

output "subnet_core_cidr" {
  description = "CIDR range of the core subnet (backend / NAT egress)."
  value       = var.ip_ranges.core
}

output "bastion_ssh_command" {
  description = "SSH command to connect to the bastion host via IAP tunnel. Requires gcloud and IAP permissions."
  value       = var.enable_bastion ? "gcloud compute ssh ${local.bastion_name} --tunnel-through-iap --project=${var.project_id} --zone=${var.zone}" : "Bastion not enabled. Use IAP tunnel to access instances directly."
}

output "bastion_name" {
  description = "Name of the bastion instance (if enabled)."
  value       = var.enable_bastion ? google_compute_instance.bastion[0].name : "N/A (bastion disabled)"
}

output "verify_segmentation_command" {
  description = "Command to verify segmentation. SSH into the bastion, then ping an instance in the core subnet. It should fail — that's the lateral movement prevention working."
  value = <<-EOT
    # Step 1: Deploy a test instance in the core subnet
    gcloud compute instances create ${local.name_prefix}-test-core \
      --zone=${var.zone} \
      --subnet=${local.subnet_core} \
      --tags=core-tier \
      --no-address \
      --machine-type=f1-micro \
      --image-family=ubuntu-2204-lts \
      --image-project=ubuntu-os-cloud

    # Step 2: SSH to bastion
    gcloud compute ssh ${local.bastion_name} --tunnel-through-iap --zone=${var.zone}

    # Step 3: From bastion, try to ping the test instance (should SUCCEED — bastion is allowed)
    ping -c 2 $(gcloud compute instances describe ${local.name_prefix}-test-core --zone=${var.zone} --format='get(networkInterfaces[0].networkIP)')

    # Step 4: Deploy a test instance in the access subnet with access-tier tag, then try pinging core
    # This tests lateral movement prevention
    gcloud compute instances create ${local.name_prefix}-test-access \
      --zone=${var.zone} \
      --subnet=${local.subnet_access} \
      --tags=access-tier \
      --no-address \
      --machine-type=f1-micro \
      --image-family=ubuntu-2204-lts \
      --image-project=ubuntu-os-cloud

    # SSH into the access-tier instance
    gcloud compute ssh ${local.name_prefix}-test-access --tunnel-through-iap --zone=${var.zone}

    # Try pinging the core instance (should FAIL — deny_access_to_core rule blocks it)
    ping -c 2 $(gcloud compute instances describe ${local.name_prefix}-test-core --zone=${var.zone} --format='get(networkInterfaces[0].networkIP)')
  EOT
}

output "cost_warning" {
  description = "Cost reminder. Read this carefully before leaving resources running."
  value = <<-EOT
    ╔══════════════════════════════════════════════════════╗
    ║  COST WARNING                                        ║
    ╠══════════════════════════════════════════════════════╣
    ║ Cloud NAT: ~$0.04/day (not free tier eligible)      ║
    ║ f1-micro bastion: free (one per billing account)    ║
    ║                                                      ║
    ║ Run 'terraform destroy' when done to avoid charges.  ║
    ╚══════════════════════════════════════════════════════╝
  EOT
  sensitive = false
}
