resource "google_service_account" "snapshot_sa" {
  account_id   = "snapshot-cleanup-sa"
  display_name = "Snapshot Cleanup Cloud Run Job SA"
}

resource "google_project_iam_member" "compute_snapshot_admin" {
  project = var.project_id
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.snapshot_sa.email}"
}

resource "google_project_iam_member" "gcs_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.snapshot_sa.email}"
}

resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.snapshot_sa.email}"
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.snapshot_sa.email}"
}
