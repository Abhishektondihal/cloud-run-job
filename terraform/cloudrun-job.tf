resource "google_cloud_run_v2_job" "snapshot_cleanup" {
  name     = "snapshot-cleanup-job"
  location = var.region

  template {
    template {
      service_account = google_service_account.snapshot_sa.email

      containers {
        image = var.image

        env {
          name  = "PROJECT_IDS"
          value = var.project_ids
        }

        env {
          name  = "GCS_BUCKET"
          value = var.gcs_bucket
        }

        env {
          name  = "DAYS_THRESHOLD"
          value = var.days_threshold
        }

        env {
          name  = "JOB_NAME"
          value = "snapshot-cleanup"
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }

      timeout     = "3600s"
      max_retries = 1
    }
  }
}
