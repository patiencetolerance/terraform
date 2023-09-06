variable "project" {
  description = "The ID of the project in which to provision resources."
  type        = string
}


variable "location" {
  description = "GCP region where the resource are present"
  type        = string
}

variable "repository_id" {
  description = " The last part of the repository name, for example: 'repo1'"
  type        = string
}

variable "format" {
  description = "The format of packages that are stored in the repository. Supported formats can be found here."
  type        = string
}

variable "kms_key_name" {
  description = "The Cloud KMS resource name of the customer managed encryption key that’s used to encrypt the contents of the Repository. Has the form: projects/my-project/locations/my-region/keyRings/my-kr/cryptoKeys/my-key. This value may not be changed after the Repository has been created."
  type        = string
}

variable "labels" {
  description = "Labels with user-defined metadata. This field may contain up to 64 entries. Label keys and values may be no longer than 63 characters. Label keys must begin with a lowercase letter and may only contain lowercase letters, numeric characters, underscores, and dashes."
  type        = map(string)
  default     = {}
}

variable "description" {
  type    = string
  default = ""
}