provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("D:/terraform/terraform/environments/staging/protean-onest-uat-3b4c587c5134.json")
}

provider "google-beta" {
  project = var.project_id
}
