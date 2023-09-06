
resource "google_project_iam_custom_role" "my_custom_role" {

  project     = var.project
  role_id     = var.role_id
  title       = var.role_id
  stage       = "GA"
  permissions = var.permissions
}
