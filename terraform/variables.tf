variable "region" {
  default = "us-central1"
}

variable "image" {
  type = string
}

variable "project_id" {
  description = "Comma separated project IDs"
  type        = string
}

variable "gcs_bucket" {
  type = string
}

variable "days_threshold" {
  default = "-1"
}

variable "scheduler_cron" {
  default = "*/4 * * * *"
}

variable "scheduler_timezone" {
  default = "Asia/Kolkata"
}
