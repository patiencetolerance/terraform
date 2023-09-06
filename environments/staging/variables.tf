/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# /**************************
#   Global Variables
#  **************************/

variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "GCP region where the resource are present"
  type        = string
}

variable "zone" {
  description = "The zone for the master instance, it should be something like: `asia-south1-a`, `us-central1-a`, `us-east1-c`."
  type        = string
}

# /*****************************************************
#   Variables of VPC Resources
#  *****************************************************/

variable "network_name" {
  description = "The VPC name to be created"
}

variable "subnets" {
  type        = list(map(string))
  description = "The list of subnets being created"
}

variable "secondary_ranges" {
  type        = map(list(object({ range_name = string, ip_cidr_range = string })))
  description = "Secondary ranges that will be used in some of the subnets"
  default     = {}
}

variable "routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "The network routing mode (default 'GLOBAL')"
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "When set to true, the network is created in 'auto subnet mode' and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in 'custom subnet mode' so the user can explicitly connect subnetwork resources."
}


variable "vpc_description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated to modify this field."
  default     = "This VPC network will be used for staging-apps Project"
}

variable "mtu" {
  type        = number
  description = "The network MTU. Must be a value between 1460 and 1500 inclusive. If set to 0 (meaning MTU is unset), the network will default to 1460 automatically."
  default     = 0
}

variable "vpc_connector_min_throughput" {
  type        = number
  description = "Min Throughput for VPC Connector backend instances"
}

variable "vpc_connector_max_throughput" {
  type        = number
  description = "Min Throughput for VPC Connector backend instances"
}

variable "vpc_connector_instance_min_count" {
  type        = number
  description = "Min Instance Count for VPC Connector backend instances"
}

variable "vpc_connector_instance_max_count" {
  type        = number
  description = "Max Instance Count for VPC Connector backend instances"
}

variable "vpc_connector_subnet_range_asia_south1" {
  type        = string
  description = "The range for subnet used by VPC Connector"
}

variable "vpc_connector_subnet_range_asia_south2" {
  type        = string
  description = "The range for subnet used by VPC Connector"
}

variable "vpc_connector_size" {
  type        = string
  description = "The VM Size used by VPC Connector"
}

# /*****************************************************
#   Variables of Cloud NAT Resources
#  *****************************************************/

variable "mum_nat_gw_name" {
  type        = string
  description = "Name of the Cloud Nat Gateway resource"
}

variable "mum_nat_gw_router_name" {
  type        = string
  description = "Name of the Cloud Router Used by Nat"
}

# /*****************************************************
#   Variables of Private Service Access Resources
#  *****************************************************/

variable "psc_name" {
  description = "Name of private service connection"
}

variable "psc_address" {
  description = "First IP address of the IP range to allocate to CLoud SQL instances and other Private Service Access services. If not set, GCP will pick a valid one for you."
  type        = string
  default     = ""
}

variable "psc_prefix_length" {
  description = "Prefix length of the IP range reserved for Cloud SQL instances and other Private Service Access services. Defaults to /16."
  type        = number
  default     = 16
}

#######################
## Registry Service ##
#######################

# /*****************************************************
#   Variables of Cloud SQL Resources
#  *****************************************************/

variable "rg_pg_sql_name" {
  type        = string
  description = "The name for Cloud SQL instance"
  default     = ""
}

variable "rg_database_version" {
  description = "The database version to use"
  type        = string
}

variable "rg_deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance."
  type        = bool
  default     = true
}

variable "rg_encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption"
  type        = string
  default     = null
}

variable "rg_tier" {
  description = "The tier for the master instance."
  type        = string
  default     = "db-n1-standard-1"
}

variable "rg_availability_type" {
  description = "The availability type for the master instance. Can be either `REGIONAL` or `ZONAL`."
  type        = string
  default     = "REGIONAL"
}

variable "rg_deletion_protection_enabled" {
  description = "Enables deletion protection of an instance at the GCP level. Can be either `true` or `false`."
  type        = string
  default     = "false"
}


variable "rg_activation_policy" {
  description = "The activation policy for the master instance.Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

variable "rg_disk_autoresize" {
  description = "Configuration to increase storage size."
  type        = bool
  default     = true
}

variable "rg_disk_autoresize_limit" {
  description = "The maximum size to which storage can be auto increased."
  type        = number
  default     = 0
}

variable "rg_disk_size" {
  description = "The disk size for the master instance."
  default     = 10
}

variable "rg_disk_type" {
  description = "The disk type for the master instance."
  type        = string
  default     = "PD_SSD"
}

variable "rg_pricing_plan" {
  description = "The pricing plan for the master instance."
  type        = string
  default     = "PER_USE"
}

variable "rg_maintenance_window_day" {
  description = "The day of week (1-7) for the master instance maintenance."
  type        = number
  default     = 1
}

variable "rg_maintenance_window_hour" {
  description = "The hour of day (0-23) maintenance window for the master instance maintenance."
  type        = number
  default     = 23
}

variable "rg_maintenance_window_update_track" {
  description = "The update track of maintenance window for the master instance maintenance.Can be either `canary` or `stable`."
  type        = string
  default     = "stable"
}

variable "rg_database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server. See [more details](https://cloud.google.com/sql/docs/mysql/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "rg_user_labels" {
  type        = map(string)
  default     = {}
  description = "The key/value labels for the master instances."
}

variable "rg_user_name" {
  description = "The name of the default user"
  type        = string
  default     = "default"
}

variable "rg_db_name" {
  description = "The name of the default database to create"
  type        = string
  default     = "default"
}

variable "rg_enable_default_db" {
  description = "Enable or disable the creation of the default database"
  type        = bool
  default     = true
}

variable "rg_enable_default_user" {
  description = "Enable or disable the creation of the default user"
  type        = bool
  default     = false
}

variable "rg_backup_configuration" {
  description = "The backup_configuration settings subblock for the database setings"
  type = object({
    enabled                        = bool
    start_time                     = string
    location                       = string
    point_in_time_recovery_enabled = bool
    transaction_log_retention_days = string
    retained_backups               = number
    retention_unit                 = string
  })
  default = {
    enabled                        = false
    start_time                     = null
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = null
    retention_unit                 = null
  }
}

variable "rg_ip_configuration" {
  description = "The ip configuration for the master instances."
  type = object({
    authorized_networks = list(map(string))
    ipv4_enabled        = bool
    private_network     = string
    require_ssl         = bool
    allocated_ip_range  = string
  })
  default = {
    authorized_networks = []
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = null
    allocated_ip_range  = null
  }
}

variable "rg_insights_config" {
  description = "The insights_config settings for the database."
  type = object({
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
  })
  default = null
}

variable "rg_read_replicas" {
  description = "List of read replicas to create. Encryption key is required for replica in different region. For replica in same region as master set encryption_key_name = null"
  type = list(object({
    name                  = string
    tier                  = string
    availability_type     = string
    zone                  = string
    disk_type             = string
    disk_autoresize       = bool
    disk_autoresize_limit = number
    disk_size             = string
    user_labels           = map(string)
    database_flags = list(object({
      name  = string
      value = string
    }))
    ip_configuration = object({
      authorized_networks = list(map(string))
      ipv4_enabled        = bool
      private_network     = string
      require_ssl         = bool
      allocated_ip_range  = string
    })
    encryption_key_name = string
  }))
  default = []
}

# /*****************************************************
#   Variables of Cloud Run Resources
#  *****************************************************/

variable "secondary_location" {
  description = "GCP region where the resource are present"
  type        = string
}

variable "mum_reg_service_name" {
  description = "The name of the Mumbai Cloud Run service to create"
  type        = string
}

variable "del_reg_service_name" {
  description = "The name of the Delhi Cloud Run service to create"
  type        = string
}

variable "rg_image" {
  description = "GCR hosted image URL to deploy"
  type        = string
}

// template spec

variable "rg_container_concurrency" {
  type        = number
  description = "Concurrent request limits to the service"
  default     = null
}

# template spec container
# resources
# cpu = (core count * 1000)m
# memory = (size) in Mi/Gi
variable "rg_limits" {
  type        = map(string)
  description = "Resource limits to the container"
  default     = null
}
variable "rg_requests" {
  type        = map(string)
  description = "Resource requests to the container"
  default     = {}
}

variable "service_account_email" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "rg_mum_template_annotations" {
  type        = map(string)
  description = "Annotations to the container metadata including VPC Connector and SQL. See [more details](https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate)"
  default = {
    "run.googleapis.com/client-name"   = "terraform"
    "generated-by"                     = "terraform"
    "autoscaling.knative.dev/maxScale" = 2
    "autoscaling.knative.dev/minScale" = 1
  }
}

variable "rg_del_template_annotations" {
  type        = map(string)
  description = "Annotations to the container metadata including VPC Connector and SQL. See [more details](https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate)"
  default = {
    "run.googleapis.com/client-name"   = "terraform"
    "generated-by"                     = "terraform"
    "autoscaling.knative.dev/maxScale" = 2
    "autoscaling.knative.dev/minScale" = 1
  }
}

variable "rg_template_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the container metadata"
  default     = {}
}

variable "rg_ports" {
  type = object({
    name = string
    port = number
  })
  description = "Port which the container listens to (http1 or h2c)"
  default = {
    name = "http1"
    port = 8080
  }
}

variable "rg_env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables (cleartext)"
  default     = []
}

variable "rg_env_secret_vars" {
  type = list(object({
    name = string
    value_from = set(object({
      secret_key_ref = map(string)
    }))
  }))
  description = "[Beta] Environment variables (Secret Manager)"
  default     = []
}

variable "rg_volumes" {
  type = list(object({
    name = string
    secret = set(object({
      secret_name = string
      items       = map(string)
    }))
  }))
  description = "[Beta] Volumes needed for environment variables (when using secret)"
  default     = []
}

variable "rg_volume_mounts" {
  type = list(object({
    mount_path = string
    name       = string
  }))
  description = "[Beta] Volume Mounts to be attached to the container (when using secret)"
  default     = []
}

#######################
## Gateway Service ##
#######################

# /*****************************************************
#   Variables of Cloud SQL Resources
#  *****************************************************/

variable "gw_pg_sql_name" {
  type        = string
  description = "The name for Cloud SQL instance"
  default     = ""
}

variable "gw_database_version" {
  description = "The database version to use"
  type        = string
}

variable "gw_deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance."
  type        = bool
  default     = true
}

variable "gw_encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption"
  type        = string
  default     = null
}

variable "gw_tier" {
  description = "The tier for the master instance."
  type        = string
  default     = "db-n1-standard-1"
}

variable "gw_availability_type" {
  description = "The availability type for the master instance. Can be either `REGIONAL` or `ZONAL`."
  type        = string
  default     = "REGIONAL"
}

variable "gw_deletion_protection_enabled" {
  description = "Enables deletion protection of an instance at the GCP level. Can be either `true` or `false`."
  type        = string
  default     = "false"
}


variable "gw_activation_policy" {
  description = "The activation policy for the master instance.Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

variable "gw_disk_autoresize" {
  description = "Configuration to increase storage size."
  type        = bool
  default     = true
}

variable "gw_disk_autoresize_limit" {
  description = "The maximum size to which storage can be auto increased."
  type        = number
  default     = 0
}

variable "gw_disk_size" {
  description = "The disk size for the master instance."
  default     = 10
}

variable "gw_disk_type" {
  description = "The disk type for the master instance."
  type        = string
  default     = "PD_SSD"
}

variable "gw_pricing_plan" {
  description = "The pricing plan for the master instance."
  type        = string
  default     = "PER_USE"
}

variable "gw_maintenance_window_day" {
  description = "The day of week (1-7) for the master instance maintenance."
  type        = number
  default     = 1
}

variable "gw_maintenance_window_hour" {
  description = "The hour of day (0-23) maintenance window for the master instance maintenance."
  type        = number
  default     = 23
}

variable "gw_maintenance_window_update_track" {
  description = "The update track of maintenance window for the master instance maintenance.Can be either `canary` or `stable`."
  type        = string
  default     = "stable"
}

variable "gw_database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server. See [more details](https://cloud.google.com/sql/docs/mysql/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "gw_user_labels" {
  type        = map(string)
  default     = {}
  description = "The key/value labels for the master instances."
}

variable "gw_user_name" {
  description = "The name of the default user"
  type        = string
  default     = "default"
}

variable "gw_db_name" {
  description = "The name of the default database to create"
  type        = string
  default     = "default"
}

variable "gw_enable_default_db" {
  description = "Enable or disable the creation of the default database"
  type        = bool
  default     = true
}

variable "gw_enable_default_user" {
  description = "Enable or disable the creation of the default user"
  type        = bool
  default     = false
}

variable "gw_backup_configuration" {
  description = "The backup_configuration settings subblock for the database setings"
  type = object({
    enabled                        = bool
    start_time                     = string
    location                       = string
    point_in_time_recovery_enabled = bool
    transaction_log_retention_days = string
    retained_backups               = number
    retention_unit                 = string
  })
  default = {
    enabled                        = false
    start_time                     = null
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = null
    retention_unit                 = null
  }
}

variable "gw_ip_configuration" {
  description = "The ip configuration for the master instances."
  type = object({
    authorized_networks = list(map(string))
    ipv4_enabled        = bool
    private_network     = string
    require_ssl         = bool
    allocated_ip_range  = string
  })
  default = {
    authorized_networks = []
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = null
    allocated_ip_range  = null
  }
}

variable "gw_insights_config" {
  description = "The insights_config settings for the database."
  type = object({
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
  })
  default = null
}

variable "gw_read_replicas" {
  description = "List of read replicas to create. Encryption key is required for replica in different region. For replica in same region as master set encryption_key_name = null"
  type = list(object({
    name                  = string
    tier                  = string
    availability_type     = string
    zone                  = string
    disk_type             = string
    disk_autoresize       = bool
    disk_autoresize_limit = number
    disk_size             = string
    user_labels           = map(string)
    database_flags = list(object({
      name  = string
      value = string
    }))
    ip_configuration = object({
      authorized_networks = list(map(string))
      ipv4_enabled        = bool
      private_network     = string
      require_ssl         = bool
      allocated_ip_range  = string
    })
    encryption_key_name = string
  }))
  default = []
}

# /*****************************************************
#   Variables of Cloud Run Resources
#  *****************************************************/

variable "mum_gw_service_name" {
  description = "The name of the Mumbai Cloud Run service to create"
  type        = string
}

variable "del_gw_service_name" {
  description = "The name of the Delhi Cloud Run service to create"
  type        = string
}

variable "gw_image" {
  description = "GCR hosted image URL to deploy"
  type        = string
}

// template spec

variable "gw_container_concurrency" {
  type        = number
  description = "Concurrent request limits to the service"
  default     = null
}

# template spec container
# resources
# cpu = (core count * 1000)m
# memory = (size) in Mi/Gi
variable "gw_limits" {
  type        = map(string)
  description = "Resource limits to the container"
  default     = null
}
variable "gw_requests" {
  type        = map(string)
  description = "Resource requests to the container"
  default     = {}
}

variable "gw_service_account_email" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "gw_argument" {
  type        = list(string)
  description = "Container args to be passed for cloud run"
}

variable "gw_mum_template_annotations" {
  type        = map(string)
  description = "Annotations to the container metadata including VPC Connector and SQL. See [more details](https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate)"
  default = {
    "run.googleapis.com/client-name"   = "terraform"
    "generated-by"                     = "terraform"
    "autoscaling.knative.dev/maxScale" = 2
    "autoscaling.knative.dev/minScale" = 1
  }
}

variable "gw_del_template_annotations" {
  type        = map(string)
  description = "Annotations to the container metadata including VPC Connector and SQL. See [more details](https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate)"
  default = {
    "run.googleapis.com/client-name"   = "terraform"
    "generated-by"                     = "terraform"
    "autoscaling.knative.dev/maxScale" = 2
    "autoscaling.knative.dev/minScale" = 1
  }
}

variable "gw_template_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the container metadata"
  default     = {}
}

variable "gw_ports" {
  type = object({
    name = string
    port = number
  })
  description = "Port which the container listens to (http1 or h2c)"
  default = {
    name = "http1"
    port = 8080
  }
}

variable "gw_env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables (cleartext)"
  default     = []
}

variable "gw_env_secret_vars" {
  type = list(object({
    name = string
    value_from = set(object({
      secret_key_ref = map(string)
    }))
  }))
  description = "[Beta] Environment variables (Secret Manager)"
  default     = []
}

variable "gw_volumes" {
  type = list(object({
    name = string
    secret = set(object({
      secret_name = string
      items       = map(string)
    }))
  }))
  description = "[Beta] Volumes needed for environment variables (when using secret)"
  default     = []
}

variable "gw_volume_mounts" {
  type = list(object({
    mount_path = string
    name       = string
  }))
  description = "[Beta] Volume Mounts to be attached to the container (when using secret)"
  default     = []
}

# /*****************************************************
#   Variables of Cloud Load balancer Resources
#  *****************************************************/

## Common Variables
variable "old_gw_rg_domain_name" {
  type        = list(string)
  description = "Domain name"
}

variable "secondary_region" {
  description = "Location for load balancer and Cloud Run resources"
  default     = "asia-south2"
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}

variable "lb_name" {
  description = "Name for load balancer and associated resources"
  default     = "tf-cr-lb"
}

variable "gw_domain_name" {
  type        = list(string)
  description = "Domain name"
}

variable "rg_domain_name" {
  type        = list(string)
  description = "Domain name"
}

variable "labels" {
  description = "The labels to attach to resources created by this module"
  type        = map(string)
  default     = {}
}

variable "address" {
  type        = string
  description = "Existing IPv4 address to use (the actual IP address value)"
  default     = null
}

variable "ssl_certificates" {
  description = "SSL cert self_link list. Required if `ssl` is `true` and no `private_key` and `certificate` is provided."
  type        = list(string)
  default     = []
}

variable "use_ssl_certificates" {
  description = "If true, use the certificates provided by `ssl_certificates`, otherwise, create cert from `private_key` and `certificate`"
  type        = bool
  default     = true
}

#disable google managed cert
# variable "managed_ssl_certificate_domains" {
#   description = "Create Google-managed SSL certificates for specified domains. Requires `ssl` to be set to `true` and `use_ssl_certificates` set to `false`."
#   type        = list(string)
#   default     = []
# }

## Armor

variable "policy_name" {
  description = "Name of the security policy."
  type        = string
}

variable "layer_7_ddos_defense_enable" {
  description = "(Optional) If set to true, enables Cloud Armor Adaptive Protection for L7 DDoS detection. Cloud Armor Adaptive Protection is currently not supported for CLOUD_ARMOR_EDGE policy type"
  type        = bool
  default     = false
}

variable "custom_rules" {
  description = "Custome security rules"
  type = map(object({
    action      = string
    priority    = number
    description = optional(string)
    preview     = optional(bool, false)
    expression  = string
  }))
  default = {}
}

# /*****************************************************
#   Variables of Virtual Machine Resources
#  *****************************************************/
#commenting elk vm provision for now

# variable "vmname" {
#   description = "Name of the VM-Series instance."
#   type        = string
# }

# variable "vmseries_image" {
#   description = <<EOF
#   The image name from which to boot an instance, including the license type and the version.
#   To get a list of available official images, please run the following command:
#   `gcloud compute images list --filter="name ~ vmseries" --project paloaltonetworksgcp-public --no-standard-images`
#   EOF
#   default     = "vmseries-flex-bundle1-1008h8"
#   type        = string
# }

# variable "image_project" {
#   type        = string
#   description = "The project in which the resource belongs."
# }

# variable "machine_type" {
#   description = "Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
#   default     = "n1-standard-1"
#   type        = string
# }

# variable "disk_size" {
#   type        = string
#   description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
#   default     = null
# }

# variable "vm_subnet_name" {
#   description = "Name of subnet where VM will be deployed"
# }

# variable "service_account" {
#   description = "IAM Service Account for running firewall instance (just the email)"
#   default     = null
#   type        = string
# }

# variable "tags" {
#   description = "GCP instance Network tags."
#   default     = []
#   type        = list(string)
# }

# variable "data_disk_count" {
#   type        = number
#   description = "Number of data disk to attach"
# }

# variable "data_disk_type" {
#   type        = string
#   description = "Type of Data disk resource"
# }

# variable "data_disk_size" {
#   type        = string
#   description = "Size of Data disk resource"
# }

variable "db_vmname" {
  description = "Name of the VM-Series instance."
  type        = string
}

variable "db_custom_image" {
  description = "The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides official image specified using `vmseries_image`."
  default     = null
  type        = string
}

# variable "db_vmseries_image" {
#   description = <<EOF
#   The image name from which to boot an instance, including the license type and the version.
#   To get a list of available official images, please run the following command:
#   `gcloud compute images list --filter="name ~ vmseries" --project paloaltonetworksgcp-public --no-standard-images`
#   EOF
#   type        = string
# }

# variable "db_image_project" {
#   type        = string
#   description = "The project in which the resource belongs."
# }

variable "db_machine_type" {
  description = "Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
  default     = "n1-standard-1"
  type        = string
}

variable "db_disk_size" {
  type        = string
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  default     = null
}

variable "db_vm_subnet_name" {
  description = "Name of subnet where VM will be deployed"
}

variable "db_service_account" {
  description = "IAM Service Account for running firewall instance (just the email)"
  default     = null
  type        = string
}

variable "db_tags" {
  description = "GCP instance Network tags."
  default     = []
  type        = list(string)
}

variable "db_labels" {
  description = "The labels to attach to resources created by this module"
  type        = map(string)
  default     = {}
}

variable "tool_vmname" {
  description = "Name of the VM-Series instance."
  type        = string
}

variable "tool_custom_image" {
  description = "The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides official image specified using `vmseries_image`."
  default     = null
  type        = string
}

variable "tool_machine_type" {
  description = "Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
  default     = "n1-standard-1"
  type        = string
}

variable "tool_disk_size" {
  type        = string
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  default     = null
}

variable "tool_disk_type" {
  description = "Boot disk type. See [provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#type) for available values."
  default     = "pd-standard"
}

variable "tool_vm_subnet_name" {
  description = "Name of subnet where VM will be deployed"
}

variable "tool_service_account" {
  description = "IAM Service Account for running firewall instance (just the email)"
  default     = null
  type        = string
}

variable "tool_tags" {
  description = "GCP instance Network tags."
  default     = []
  type        = list(string)
}

variable "tool_labels" {
  description = "The labels to attach to resources created by this module"
  type        = map(string)
  default     = {}
}

variable "tool_scopes" {
  default = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
  type = list(string)
}  