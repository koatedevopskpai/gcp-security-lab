variable "project_id" { type = string }
variable "region" { type = string; default = "us-central1" }
variable "creator" { type = string }
variable "destroy_after" { type = string; default = "2026-08-20" }
variable "module_name" { type = string; default = "07-dlp-endpoint" }
variable "extra_tags" { type = map(string); default = {} }
