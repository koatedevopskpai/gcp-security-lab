output "project_id" { value = var.project_id }
output "vm_name" { value = google_compute_instance.main.name }
output "vm_external_ip" { value = google_compute_instance.main.network_interface[0].access_config[0].nat_ip }
output "log_metric_name" { value = google_logging_metric.ssh_attempts.name }
output "alert_policy_name" { value = google_monitoring_alert_policy.high_ssh.display_name }
output "alert_policy_id"  { value = google_monitoring_alert_policy.high_ssh.name }
output "logging_url" {
  value = "https://console.cloud.google.com/logs/query;query=resource.type%3D%22gce_subnetwork%22;?project=${var.project_id}"
}
output "monitoring_url" {
  value = "https://console.cloud.google.com/monitoring/alerting?project=${var.project_id}"
}
