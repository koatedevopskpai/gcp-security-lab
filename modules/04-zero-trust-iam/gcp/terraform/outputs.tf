output "project_id" { value = var.project_id }
output "vm_name" { value = google_compute_instance.main.name }
output "vm_zone" { value = google_compute_instance.main.zone }
output "service_account_email" { value = google_service_account.main.email }
output "custom_role_id" { value = google_project_iam_custom_role.main.role_id }
output "bucket_name" { value = google_storage_bucket.main.name }
output "iap_ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.main.name} --zone ${google_compute_instance.main.zone} --tunnel-through-iap"
}
