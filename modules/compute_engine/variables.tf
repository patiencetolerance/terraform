variable "custom_image" {
  description = "The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides official image specified using `vmseries_image`."
  default     = null
  type        = string
}

variable "vmseries_image" {
  description = <<EOF
  The image name from which to boot an instance, including the license type and the version.
  To get a list of available official images, please run the following command:
  `gcloud compute images list --filter="name ~ vmseries" --project paloaltonetworksgcp-public --no-standard-images`
  EOF
  default     = null
  type        = string
}

variable "image_project" {
  type        = string
  description = "The project in which the resource belongs."
  default = null
}

variable "enable_public_ip_address" {
  description = "Reference to a Public IP Address to associate with the NIC"
  default     = null
}

variable "network" {
  description = "Network to deploy to. Only one of network or subnetwork should be specified."
  default     = ""
}

variable "subnetwork" {
  description = "Subnet to deploy to. Only one of network or subnetwork should be specified."
  default     = ""
}

variable "region" {
  type        = string
  default     = ""
  description = "The Region in which the created address should reside. If it is not provided, the provider region is used."
}

variable "name" {
  description = "Name of the VM-Series instance."
  type        = string
}

variable "zone" {
  description = "Zone to deploy instance in."
  type        = string
}

variable "machine_type" {
  description = "Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
  default     = "n1-standard-1"
  type        = string
}

variable "labels" {
  description = "GCP instance lables."
  default     = {}
  type        = map(any)
}

variable "tags" {
  description = "GCP instance tags."
  default     = []
  type        = list(string)
}

variable "metadata_startup_script" {
  description = "See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
  default     = null
  type        = string
}

variable "project_id" {
  default = null
  type    = string
}

variable "resource_policies" {
  default = []
  type    = list(string)
}

variable "ssh_keys" {
  description = "Public keys to allow SSH access for, separated by newlines."
  default     = null
  type        = string
}

variable "bootstrap_options" {
  description = "VM-Series bootstrap options to pass using instance metadata."
  default     = null
  type        = map(string)
}

variable "metadata" {
  description = "Other, not VM-Series specific, metadata to set for an instance."
  default     = {}
  type        = map(string)
}

variable "service_account" {
  description = "IAM Service Account for running firewall instance (just the email)"
  default     = null
  type        = string
}

variable "scopes" {
  default = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
  type = list(string)
}

variable "network_interfaces" {
  type        = string
  default     = null
  description = "In"
}

variable "private_address" {
  description = "Static IP for VM instance"
  default     = null
}

variable "alias_ip_ranges" {
  description = "(Optional) An array of alias IP ranges for this network interface. Can only be specified for network interfaces on subnet-mode networks."
  type = list(object({
    ip_cidr_range         = string
    subnetwork_range_name = string
  }))
  default = []
}

variable "disk_type" {
  description = "Boot disk type. See [provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#type) for available values."
  default     = "pd-standard"
}

variable "disk_size" {
  type        = string
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  default     = null
}

variable "preemptible" {
  type        = bool
  description = "Specifies if the instance is preemptible."
  default     = false
}