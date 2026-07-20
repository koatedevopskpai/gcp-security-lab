# ------------------------------------------------------------------------------
# SDCI Lab 07 — Data Loss Prevention & Endpoint Security (GCP)
# main.tf
#
# Uses Cloud DLP to inspect data for sensitive content (PII, credentials, etc.)
# and de-identify it before storage or sharing.
#
# Pipeline:
#   1. GCS bucket stores sample sensitive data (fake PII)
#   2. DLP inspect template detects credit cards, SSNs, emails
#   3. DLP job trigger runs scans on new bucket objects
#   4. DLP de-identify template redacts matched content
#
# COST: DLP free tier (first 500 GB inspect/month, first 5 templates)
# --------------------------------------------------------------------------

# DLP must be enabled via service API
resource "google_project_service" "dlp" {
  service = "dlp.googleapis.com"
  disable_on_destroy = false
}

# --------------------------------------------------------------------------
# GCS BUCKET — stores sample sensitive data for DLP to inspect
# --------------------------------------------------------------------------
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "data" {
  name          = "${local.bucket_name}-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = true
  labels        = local.labels
}

# Sample sensitive data files (generated, not real PII)
resource "google_storage_bucket_object" "customers_csv" {
  name         = "sample-data/customers.csv"
  bucket       = google_storage_bucket.data.name
  content      = <<-EOT
name,email,phone,ssn,cc_number
Alice Smith,alice@example.com,555-0101,123-45-6789,4111-1111-1111-1111
Bob Jones,bob@test.org,555-0102,987-65-4321,5500-0000-0000-0004
Carol Lee,carol@demo.net,555-0103,456-78-9012,3400-0000-0000-0009
EOT
}

resource "google_storage_bucket_object" "config_json" {
  name         = "sample-data/config.json"
  bucket       = google_storage_bucket.data.name
  content      = jsonencode({
    database = "production"
    host     = "10.0.1.50"
    password = "SuperSecret1!"
    api_key  = "AIzaSyD-NotARealKey-Example"
    users = [
      { name = "admin", email = "admin@corp.com", role = "admin" }
    ]
  })
}

resource "google_storage_bucket_object" "readme" {
  name         = "README.txt"
  bucket       = google_storage_bucket.data.name
  content      = "SDCI Lab 07 — This bucket contains sample sensitive data for DLP inspection."
}

# --------------------------------------------------------------------------
# DLP INSPECT TEMPLATE — defines what sensitive data to look for
# Built-in info types: CREDIT_CARD_NUMBER, US_SOCIAL_SECURITY_NUMBER, etc.
# --------------------------------------------------------------------------
resource "google_data_loss_prevention_inspect_template" "main" {
  parent       = "projects/${var.project_id}"
  display_name = "sdci-07-dlp-inspect"
  description  = "SDCI Lab 07 — Detect PII: credit cards, SSNs, emails, passwords"

  inspect_config {
    min_likelihood = "POSSIBLE"
    include_quote  = true

    info_types {
      name = "CREDIT_CARD_NUMBER"
    }
    info_types {
      name = "US_SOCIAL_SECURITY_NUMBER"
    }
    info_types {
      name = "EMAIL_ADDRESS"
    }
    info_types {
      name = "PHONE_NUMBER"
    }
    info_types {
      name = "PASSWORD"
    }

    # Custom dictionary for API keys
    custom_info_types {
      info_type { name = "API_KEY" }
      dictionary { word_list { words = ["AIzaSy", "sk_live_", "pk_live_"] } }
    }

    rulesets {
      info_types { name = "US_SOCIAL_SECURITY_NUMBER" }
      rules {
        exclusion_rule {
          regex { pattern = "000-00-0000" }
          matching_type = "MATCHING_TYPE_FULL_MATCH"
        }
      }
    }
  }
}

# --------------------------------------------------------------------------
# DLP DE-IDENTIFY TEMPLATE — defines how to redact matched content
# --------------------------------------------------------------------------
resource "google_data_loss_prevention_deidentify_template" "main" {
  parent       = "projects/${var.project_id}"
  display_name = "sdci-07-dlp-deidentify"
  description  = "SDCI Lab 07 — Redact PII: mask credit cards, encrypt SSNs"

  deidentify_config {
    info_type_transformations {
      transformations {
        info_types { name = "CREDIT_CARD_NUMBER" }
        primitive_transformation {
          replace_with_info_type_config = true
        }
      }
      transformations {
        info_types { name = "US_SOCIAL_SECURITY_NUMBER" }
        primitive_transformation {
          replace_config {
            new_value { string_value = "[REDACTED-SSN]" }
          }
        }
      }
      transformations {
        info_types { name = "EMAIL_ADDRESS" }
        primitive_transformation {
          replace_with_info_type_config = true
        }
      }
    }
  }
}

# --------------------------------------------------------------------------
# DLP JOB TRIGGER — automatically inspects new data uploaded to the bucket
# --------------------------------------------------------------------------
resource "google_data_loss_prevention_job_trigger" "main" {
  parent       = "projects/${var.project_id}"
  display_name = "sdci-07-dlp-trigger"
  description  = "SDCI Lab 07 — Auto-inspect GCS bucket for PII"

  triggers {
    schedule {
      recurrence_period_duration = "604800s"  # weekly
    }
  }

  inspect_job {
    inspect_template_name = google_data_loss_prevention_inspect_template.main.name
    storage_config {
      cloud_storage_options {
        file_set {
          url = "gs://${google_storage_bucket.data.name}/*"
        }
      }
    }
    actions {
      save_findings {
        output_config {
          table {
            project_id = var.project_id
            dataset_id = google_bigquery_dataset.findings.dataset_id
          }
        }
      }
    }
  }
}

# BigQuery dataset for DLP findings
resource "google_bigquery_dataset" "findings" {
  dataset_id    = "sdci_07_dlp_findings"
  friendly_name = "SDCI Lab 07 — DLP Findings"
  location      = var.region
  labels        = local.labels
}
