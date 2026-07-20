output "bucket_name" { value = google_storage_bucket.data.name }
output "inspect_template_name" { value = google_data_loss_prevention_inspect_template.main.name }
output "deidentify_template_name" { value = google_data_loss_prevention_deidentify_template.main.name }
output "bigquery_dataset" { value = google_bigquery_dataset.findings.dataset_id }
output "inspect_template_id" {
  value = "projects/${var.project_id}/inspectTemplates/${google_data_loss_prevention_inspect_template.main.name}"
}
