resource "google_artifact_registry_repository" "repo" {
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format
  kms_key_name  = var.kms_key_name
  labels        = var.labels
}