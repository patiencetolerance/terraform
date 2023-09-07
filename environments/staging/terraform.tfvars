## Update following values
## 1. Project ID
## 2. All Mentioned Resource Self URL e.g. projects/terraform-scripts-1/global/networks/staging-ondc-apps-vpc
## 3. Update Service Account Email.
## 4. SQL Connection
## 5. Container Image URL
## 6. LB - Domain names, Static IP Address and SSL Certificate URL.
## 7. If required, modify resource and storage size of Cloud Run and Cloud SQL.

/* GLOBAL */
project_id         = "protean-onest-uat"
region             = "asia-south1"
zone               = "asia-south1-a"
secondary_location = "asia-south2"

/* VPC */
network_name            = "staging-ondc-apps-vpc"
vpc_description         = "staging-apps VPC"
routing_mode            = "REGIONAL"
auto_create_subnetworks = "false"
mtu                     = 1460


/* Subnets */
subnets = [
  {
    subnet_name           = "staging-apps-mgmt-asia-south1-subnet"
    subnet_ip             = "10.48.0.0/24"
    subnet_region         = "asia-south1"
    subnet_private_access = "true"
    subnet_flow_logs      = "false"
  },
  {
    subnet_name           = "staging-apps-pvt-asia-south1-subnet"
    subnet_ip             = "10.48.1.0/24"
    subnet_region         = "asia-south1"
    subnet_private_access = "true"
    subnet_flow_logs      = "false"
  },
  {
    subnet_name           = "staging-apps-db-pvt-asia-south1-subnet"
    subnet_ip             = "10.48.2.0/24"
    subnet_region         = "asia-south1"
    subnet_private_access = "true"
    subnet_flow_logs      = "false"
  }
]

vpc_connector_instance_min_count       = "2"
vpc_connector_instance_max_count       = "6"
vpc_connector_min_throughput           = "200"
vpc_connector_max_throughput           = "600"
vpc_connector_subnet_range_asia_south1 = "10.48.5.0/28"
vpc_connector_subnet_range_asia_south2 = "10.48.5.16/28"
vpc_connector_size                     = "e2-micro"

/* Cloud NAT */

mum_nat_gw_name        = "staging-ondc-apps-asia-south1-nat-gw"
mum_nat_gw_router_name = "staging-ondc-apps-asia-south1-router"

/* Private Service Access */

psc_name          = "staging-ondc-apps-vpc-psa"
psc_address       = "10.48.16.0"
psc_prefix_length = "21"


/* Common Values for Cloud Run */

# Cloud Run
service_account_email = "protean-onest-uat@protean-onest-uat.iam.gserviceaccount.com"

#######################
## Registry Service ##
#######################

/* Cloud SQL */

// Master configurations
rg_pg_sql_name           = "staging-ondc-registry-pgsql-1"
rg_tier                  = "db-custom-4-16384"
rg_disk_size             = 100
rg_disk_autoresize       = true
rg_disk_type             = "PD_SSD" #PD_SSD
rg_container_concurrency = 100

rg_database_version            = "POSTGRES_13"
rg_availability_type           = "REGIONAL" #"ZONAL" 
rg_deletion_protection_enabled = true       # Enables deletion protection on all platforms

rg_maintenance_window_day          = 6
rg_maintenance_window_hour         = 20
rg_maintenance_window_update_track = "stable"

rg_insights_config = {
  query_string_length     = 1024
  record_application_tags = true
  record_client_address   = true
}

rg_deletion_protection = false # Enables deletion protection on Terraform only
rg_encryption_key_name = null

rg_user_labels = { env = "staging", type = "master" }

rg_database_flags = [{ name = "max_connections", value = "1000" }]

rg_backup_configuration = {
  enabled                        = true
  start_time                     = "22:00"
  location                       = "asia-south1"
  point_in_time_recovery_enabled = true
  transaction_log_retention_days = null
  retained_backups               = 7
  retention_unit                 = "COUNT"
}

rg_ip_configuration = {
  ipv4_enabled        = false
  require_ssl         = false
  private_network     = "projects/ondc-stag-cloudrun/global/networks/staging-ondc-apps-vpc"
  allocated_ip_range  = null
  authorized_networks = []
}

// Read Replica configurations
rg_read_replicas = [
  {
    name                             = "-0"
    zone                             = "asia-south2-a"
    availability_type                = "REGIONAL" #"ZONAL"
    tier                             = "db-custom-4-16384"
    disk_autoresize                  = true
    disk_autoresize_limit            = 0
    disk_size                        = 100
    disk_type                        = "PD_SSD"
    user_labels                      = { env = "staging", type = "replica" }
    encryption_key_name              = null
    read_replica_deletion_protection = false
    retained_backups                 = 0
    database_flags                   = [{ name = "max_connections", value = "1000" }]
    ip_configuration = {
      ipv4_enabled        = false
      require_ssl         = false
      private_network     = "projects/ondc-stag-cloudrun/global/networks/staging-ondc-apps-vpc"
      allocated_ip_range  = null
      authorized_networks = []
    }
  }
]

/* Cloud Run */

mum_reg_service_name = "staging-ondc-registry-service-1"
del_reg_service_name = "staging-ondc-registry-service-2"
rg_image             = "asia-south1-docker.pkg.dev/ondc-stag-cloudrun/staging-ondc-apps-artifact-registry-1/ondc-onboard:5ba76e5-2.4.0-v1"

rg_mum_template_annotations = {
  "autoscaling.knative.dev/maxScale"        = 3
  "autoscaling.knative.dev/minScale"        = 1
  "generated-by"                            = "terraform"
  "run.googleapis.com/startup-cpu-boost"    = true
  "run.googleapis.com/cpu-throttling"       = false
  "run.googleapis.com/cloudsql-instances"   = "ondc-stag-cloudrun:asia-south1:staging-ondc-registry-pgsql-1"
  "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
  "run.googleapis.com/vpc-access-connector" = "projects/ondc-stag-cloudrun/locations/asia-south1/connectors/asia-south1-serverless"
}

rg_del_template_annotations = {
  "autoscaling.knative.dev/maxScale"        = 3
  "autoscaling.knative.dev/minScale"        = 1
  "generated-by"                            = "terraform"
  "run.googleapis.com/startup-cpu-boost"    = true
  "run.googleapis.com/cpu-throttling"       = false
  "run.googleapis.com/cloudsql-instances"   = "ondc-stag-cloudrun:asia-south1:staging-ondc-registry-pgsql-1"
  "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
  "run.googleapis.com/vpc-access-connector" = "projects/ondc-stag-cloudrun/locations/asia-south2/connectors/asia-south2-serverless"
}

rg_template_labels = {
  "run.googleapis.com/startupProbeType" = "Default"
}

rg_limits = {
  cpu    = "2000m"
  memory = "4Gi"
}

rg_ports = {
  name = "http1"
  port = 9002
}

rg_env_vars = [
  {
    value = "-XX:InitialRAMPercentage=30.0 -XX:MaxRAMPercentage=50.0 -XX:+PrintFlagsFinal -Dspring.profiles.active=staging -Dspring.config.location=/opt/config/application-staging-apps.properties"
    name  = "JAVA_OPTS"
  }
]

rg_env_secret_vars = [
  {
    name = "JASYPT_ENCRYPTOR_PASSWORD"
    value_from = [
      {
        secret_key_ref = {
          key : "latest"
          name : "staging-javasypt-key"
        }
      }
    ]
  }
]

rg_volumes = [
  {
    name = "staging-rg-apps-config-volume",
    secret = [
      {
        secret_name = "staging-registry-properties"
        items = {
          key  = "latest"
          path = "application-staging-apps.properties"
        }
      }
    ]
  }
]

rg_volume_mounts = [
  {
    name       = "staging-rg-apps-config-volume"
    mount_path = "/opt/config"
  }
]

#######################
## Gateway Service ##
#######################

/* Cloud SQL */

// Master configurations
gw_pg_sql_name     = "staging-ondc-gateway-pgsql-1"
gw_tier            = "db-custom-4-16384"
gw_disk_size       = 100
gw_disk_autoresize = true
gw_disk_type       = "PD_SSD" #PD_SSD

gw_database_version            = "POSTGRES_13"
gw_availability_type           = "REGIONAL" #"ZONAL" 
gw_deletion_protection_enabled = true       # Enables deletion protection on all platforms

gw_maintenance_window_day          = 6
gw_maintenance_window_hour         = 20
gw_maintenance_window_update_track = "stable"

gw_insights_config = {
  query_string_length     = 1024
  record_application_tags = true
  record_client_address   = true
}

gw_deletion_protection = false # Enables deletion protection on Terraform only
gw_encryption_key_name = null

gw_user_labels = { env = "staging-apps", type = "master" }

gw_database_flags = [{ name = "max_connections", value = "3000" }]

gw_backup_configuration = {
  enabled                        = true
  start_time                     = "22:00"
  location                       = "asia-south1"
  point_in_time_recovery_enabled = true
  transaction_log_retention_days = null
  retained_backups               = 7
  retention_unit                 = "COUNT"
}

gw_ip_configuration = {
  ipv4_enabled        = false
  require_ssl         = false
  private_network     = "projects/ondc-stag-cloudrun/global/networks/staging-ondc-apps-vpc"
  allocated_ip_range  = null
  authorized_networks = []
}

// Read Replica configurations
gw_read_replicas = [
  {
    name                             = "-0"
    zone                             = "asia-south2-a"
    availability_type                = "REGIONAL" #"ZONAL"
    tier                             = "db-custom-4-16384"
    disk_autoresize                  = true
    disk_autoresize_limit            = 0
    disk_size                        = 100
    disk_type                        = "PD_SSD"
    user_labels                      = { env = "staging", type = "replica" }
    encryption_key_name              = null
    read_replica_deletion_protection = false
    retained_backups                 = 0
    database_flags                   = [{ name = "max_connections", value = "3000" }]
    ip_configuration = {
      ipv4_enabled        = false
      require_ssl         = false
      private_network     = "projects/ondc-stag-cloudrun/global/networks/staging-ondc-apps-vpc"
      allocated_ip_range  = null
      authorized_networks = []
    }
  }
]

/* Cloud Run */

mum_gw_service_name = "staging-ondc-gateway-service-1"
del_gw_service_name = "staging-ondc-gateway-service-2"
gw_image            = "asia-south1-docker.pkg.dev/ondc-stag-cloudrun/staging-ondc-apps-artifact-registry-1/ondc-gateway:b986f6e-1.0.0-v1"

gw_mum_template_annotations = {
  "autoscaling.knative.dev/maxScale"        = 3
  "autoscaling.knative.dev/minScale"        = 1
  "generated-by"                            = "terraform"
  "run.googleapis.com/startup-cpu-boost"    = true
  "run.googleapis.com/cpu-throttling"       = false
  "run.googleapis.com/cloudsql-instances"   = "ondc-stag-cloudrun:asia-south1:staging-ondc-gateway-pgsql-1"
  "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
  "run.googleapis.com/vpc-access-connector" = "projects/ondc-stag-cloudrun/locations/asia-south1/connectors/asia-south1-serverless"
}

gw_del_template_annotations = {
  "autoscaling.knative.dev/maxScale"        = 3
  "autoscaling.knative.dev/minScale"        = 1
  "generated-by"                            = "terraform"
  "run.googleapis.com/startup-cpu-boost"    = true
  "run.googleapis.com/cpu-throttling"       = false
  "run.googleapis.com/cloudsql-instances"   = "ondc-stag-cloudrun:asia-south1:staging-ondc-gateway-pgsql-1"
  "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
  "run.googleapis.com/vpc-access-connector" = "projects/ondc-stag-cloudrun/locations/asia-south2/connectors/asia-south2-serverless"
}

gw_template_labels = {
  "run.googleapis.com/startupProbeType" = "Default"
}

gw_container_concurrency = 100

gw_limits = {
  cpu    = "2000m"
  memory = "4Gi"
}

gw_ports = {
  name = "http1"
  port = 8080
}

gw_argument = [
  "-Duser.timezone=Asia/Calcutta",
  "-Dspring.profiles.active=staging",
  "-Dspring.config.location=/opt/config/application-staging.yml",
  "-XX:InitialRAMPercentage=40.0",
  "-XX:MaxRAMPercentage=60.0",
  "com.nsdl.beckn.BecknGatewayApplication"
]

gw_volumes = [
  {
    name = "staging-gw-config-volume",
    secret = [
      {
        secret_name = "staging-gateway-yml"
        items = {
          key  = "latest"
          path = "application-staging.yml"
        }
      }
    ]
  }
]

gw_volume_mounts = [
  {
    name       = "staging-gw-config-volume"
    mount_path = "/opt/config"
  }
]


/* Cloud Load balancer */

#disable google managed cert
#managed_ssl_certificate_domains = ["staging.gateway.proteantech.in", "staging.registry.ondc.org"]

lb_name = "staging-ondc-apps-external"

old_gw_rg_domain_name = ["pilot-gateway-1.beckn.nsdl.co.in"]
gw_domain_name        = ["staging.gateway.proteantech.in"]
rg_domain_name        = ["staging.registry.ondc.org"]

address          = "34.111.248.205"
ssl_certificates = ["projects/ondc-stag-cloudrun/global/sslCertificates/staging-ondc-apps-external-cert-1", "projects/ondc-stag-cloudrun/global/sslCertificates/staging-ondc-apps-external-cert-2", "projects/ondc-stag-cloudrun/global/sslCertificates/pilot-gateway-1-beckn-nsdl-co-in"]

policy_name                 = "staging-apps-armor-policy"
layer_7_ddos_defense_enable = true

labels = {
  "env" = "staging"
}

custom_rules = {
  "ip-block-china" = {
    action      = "deny(403)"
    description = "Deny all traffic from China region"
    priority    = "1001"
    preview     = true
    expression  = "origin.region_code == 'CN'"
  },
  "ip-block-pakistan" = {
    action      = "deny(403)"
    description = "Deny all traffic from Pakistan region"
    priority    = "1002"
    preview     = true
    expression  = "origin.region_code == 'PK'"
  }
}

/* GCE */
#commenting elk vm provision for now
# vmname          = "staging-ondc-elk-vm"
# vmseries_image  = "ubuntu-2004-lts"
# image_project   = "ubuntu-os-cloud"
# machine_type    = "e2-custom-4-8192"
# disk_size       = "50"
# vm_subnet_name  = "staging-apps-mgmt-asia-south1-subnet"
# service_account = "staging-infra-mgmt-sa@ondc-stag-cloudrun.iam.gserviceaccount.com"
# tags            = ["allow-iap-access"]

# data_disk_count = 2
# data_disk_size  = "100"         #need to reconsider disk size
# data_disk_type  = "pd-standard" #change ssd to lower tier storage pd-ssd 

# Bastion Database VM to Privately Access Cloud SQL.

db_vmname          = "staging-ondc-db-vm"
db_custom_image    = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230628"
db_machine_type    = "e2-micro"
db_disk_size       = "10"
db_vm_subnet_name  = "staging-apps-mgmt-asia-south1-subnet"
db_service_account = "staging-infra-mgmt-sa@ondc-stag-cloudrun.iam.gserviceaccount.com"
db_tags            = ["allow-iap-access"]
# db_vmseries_image  = "ubuntu-2004-lts"
# db_image_project   = "ubuntu-os-cloud"
db_labels = {
  "env"     = "staging",
  "purpose" = "db_bastion"
}

# Tools Management VM to Run Application Utilities.
tool_vmname          = "staging-ondc-tools-vm"
tool_custom_image    = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230628"
tool_machine_type    = "e2-small"
tool_disk_size       = "20"
tool_disk_type       = "pd-balanced"
tool_vm_subnet_name  = "staging-apps-mgmt-asia-south1-subnet"
tool_service_account = "staging-support-automation-sa@ondc-stag-cloudrun.iam.gserviceaccount.com"
tool_tags            = ["allow-iap-access"]
tool_labels = {
  "env"     = "staging",
  "purpose" = "tools_manager"
}
tool_scopes = [
  "https://www.googleapis.com/auth/cloud-platform",
]
