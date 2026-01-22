output "job_name" {
  value = google_cloud_run_v2_job.snapshot_cleanup.name
}

output "scheduler_name" {
  value = google_cloud_scheduler_job.snapshot_trigger.name
}
