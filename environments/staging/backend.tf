terraform {
  backend "gcs" {
    bucket = "staging-ondc-apps-tfstate-bucket"
    prefix = "terraform/env/staging/apps"
  }
}