output "vm_clean_name" { value = google_compute_instance.clean.name }
output "vm_clean_ip" { value = google_compute_instance.clean.network_interface[0].access_config[0].nat_ip }
output "vm_quarantined_name" { value = google_compute_instance.quarantined.name }
output "vm_quarantined_ip" { value = google_compute_instance.quarantined.network_interface[0].access_config[0].nat_ip }
output "quarantine_tag" { value = "quarantine" }
output "quarantine_command" {
  value = "gcloud compute instances add-tags ${google_compute_instance.clean.name} --tags=quarantine --zone=${local.zone}"
}
output "release_command" {
  value = "gcloud compute instances remove-tags ${google_compute_instance.clean.name} --tags=quarantine --zone=${local.zone}"
}
