terraform {
  required_version = "> 0.13"
  required_providers {
    google      = "< 5.0, >= 3.83"
    google-beta = ">= 4.40, < 5.0"
  }
}
