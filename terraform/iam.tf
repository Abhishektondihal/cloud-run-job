resource "google_service_account" "snapshot_sa" {
  account_id   = "snapshot-cleanup-sa"
  display_name = "Snapshot Cleanup Cloud Run Job SA"
}

resource "google_service_account" "scheduler_sa" {
  account_id   = "snapshot-scheduler-sa"
  display_name = "Scheduler SA"
}

resource "google_project_iam_member" "compute_admin" {
  project = var.project_id
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.snapshot_sa.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.snapshot_sa.email}"
}

resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.snapshot_sa.email}"
}

resource "google_project_iam_member" "scheduler_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}
