output "job_name" {
  value = google_cloud_run_v2_job.snapshot_cleanup.name
}

output "scheduler_name" {
  value = google_cloud_scheduler_job.snapshot_trigger.name
}

output "wif_provider" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

output "terraform_sa_email" {
  value = google_service_account.terraform_sa.email
}
