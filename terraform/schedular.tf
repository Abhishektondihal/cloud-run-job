resource "google_project_service" "scheduler_api" {
  service = "cloudscheduler.googleapis.com"
}

resource "google_cloud_scheduler_job" "snapshot_trigger" {
  name     = "snapshot-cleanup-trigger"
  region   = var.region
  schedule = var.scheduler_cron
  time_zone = var.scheduler_timezone

  http_target {
    http_method = "POST"

    uri = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.snapshot_cleanup.name}:run"

    oauth_token {
      service_account_email = google_service_account.scheduler_sa.email
    }

    headers = {
      "Content-Type" = "application/json"
    }
  }
}
