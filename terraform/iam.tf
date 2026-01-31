data "google_project" "current" {
  project_id = var.project_id
}

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

resource "google_project_iam_member" "cloudbuild_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_compute_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

resource "google_artifact_registry_repository_iam_member" "cloudbuild_repo_writer" {
  project    = var.project_id
  location   = "us-central1"
  repository = "cloud-run-jobs"
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

# Google-managed Cloud Build SA (THIS is the missing one)
resource "google_artifact_registry_repository_iam_member" "cloudbuild_managed_repo_writer" {
  project    = var.project_id
  location   = "us-central1"
  repository = "cloud-run-jobs"
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}
