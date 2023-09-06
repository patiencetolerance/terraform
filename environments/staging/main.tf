/******************************************
	VPC configuration
 *****************************************/

module "vpc" {
  source                  = "../../modules/networking/vpc"
  project_id              = var.project_id
  network_name            = var.network_name
  routing_mode            = var.routing_mode
  description             = var.vpc_description
  shared_vpc_host         = false
  auto_create_subnetworks = false
  mtu                     = var.mtu
}

/******************************************
	Subnet configuration
 *****************************************/

module "subnets" {
  source           = "../../modules/networking/vpc_subnets"
  project_id       = var.project_id
  network_name     = module.vpc.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}

module "vpc_connector" {
  source = "../../modules/networking/vpc-serverless-connector-beta"

  project_id = var.project_id
  vpc_connectors = [
    {
      name          = "${var.region}-serverless"
      region        = var.region
      network       = var.network_name
      ip_cidr_range = var.vpc_connector_subnet_range_asia_south1
      subnet_name   = null
      # host_project_id = var.host_project_id # Specify a host_project_id for shared VPC

      machine_type   = var.vpc_connector_size
      min_instances  = var.vpc_connector_instance_min_count
      max_instances  = var.vpc_connector_instance_max_count
      min_throughput = var.vpc_connector_min_throughput
      max_throughput = var.vpc_connector_max_throughput
    },
    {
      name          = "${var.secondary_location}-serverless"
      region        = var.secondary_location
      network       = var.network_name
      ip_cidr_range = var.vpc_connector_subnet_range_asia_south2
      subnet_name   = null
      # host_project_id = var.host_project_id # Specify a host_project_id for shared VPC

      machine_type   = var.vpc_connector_size
      min_instances  = var.vpc_connector_instance_min_count
      max_instances  = var.vpc_connector_instance_max_count
      min_throughput = var.vpc_connector_min_throughput
      max_throughput = var.vpc_connector_max_throughput
    }
  ]

  depends_on = [module.subnets]
}


/******************************************
	Default Firewall Rules for GCP Project
 *****************************************/

module "allow-iap-access-fw" {
  source       = "../../modules/networking/firewall"
  network_name = var.network_name
  project_id   = var.project_id
  rules = [{
    name                    = "${var.network_name}-allow-iap-access-fw"
    description             = "Allow IAP Access"
    direction               = "INGRESS"
    ranges                  = ["35.235.240.0/20"]
    priority                = 1000
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["allow-iap-access"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22", "3389", "5432"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]

  depends_on = [module.vpc]
}

module "allow-lb-hc-fw" {
  source       = "../../modules/networking/firewall"
  network_name = var.network_name
  project_id   = var.project_id
  rules = [{
    name                    = "${var.network_name}-allow-lb-hc-fw"
    description             = "Allow Ingress LB Access"
    direction               = "INGRESS"
    ranges                  = ["209.85.204.0/22", "209.85.152.0/22", "130.211.0.0/22", "35.191.0.0/16"]
    priority                = 1000
    source_tags             = null
    source_service_accounts = null
    target_tags             = []
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = []
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]

  depends_on = [module.vpc]
}

module "default-deny-fw" {
  source       = "../../modules/networking/firewall"
  network_name = var.network_name
  project_id   = var.project_id
  rules = [{
    name                    = "${var.network_name}-default-deny-fw"
    description             = "Deny Access"
    direction               = "INGRESS"
    ranges                  = ["0.0.0.0/0"]
    priority                = 65535
    source_tags             = null
    source_service_accounts = null
    target_tags             = []
    target_service_accounts = null
    allow                   = []
    deny = [{
      protocol = "tcp"
      ports    = []
    }]
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]

  depends_on = [module.vpc]
}

/******************************************
  Resource for External Static IPs
 *****************************************/

resource "google_compute_address" "address" {
  count  = 2
  name   = "${var.mum_nat_gw_name}-pip-${count.index}"
  region = var.region
}

/******************************************
  Resource for Cloud Router for Mumbai NAT GW
 *****************************************/

resource "google_compute_router" "router" {
  name    = var.mum_nat_gw_router_name
  region  = var.region
  network = module.vpc.network_name
}

/******************************************
  Module for NAT Gateway
 *****************************************/

module "cloud-nat" {
  source                             = "../../modules/networking/nat-gateway"
  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = var.mum_nat_gw_name
  nat_ips                            = google_compute_address.address.*.self_link
  min_ports_per_vm                   = "1024"
  icmp_idle_timeout_sec              = "15"
  tcp_established_idle_timeout_sec   = "600"
  tcp_transitory_idle_timeout_sec    = "15"
  udp_idle_timeout_sec               = "15"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

/**********************************************************
  Module for Private Service Access for Internal Communication
 *********************************************************/

module "private-service-access" {
  source        = "../../modules/networking/private_service_access/"
  project_id    = var.project_id
  vpc_network   = module.vpc.network_id
  name          = var.psc_name
  address       = var.psc_address
  prefix_length = var.psc_prefix_length
}

#######################
## Registry Service ##
#######################

/******************************************
  Module for Cloud SQL
 *****************************************/

module "rg_pg" {
  source = "../../modules/cloudsql/postgresql"

  project_id           = var.project_id
  region               = var.region
  random_instance_name = false
  name                 = var.rg_pg_sql_name
  database_version     = var.rg_database_version

  deletion_protection = var.rg_deletion_protection
  encryption_key_name = var.rg_encryption_key_name

  // Master configurations
  tier                        = var.rg_tier
  zone                        = var.zone
  availability_type           = var.rg_availability_type
  deletion_protection_enabled = var.rg_deletion_protection_enabled
  activation_policy           = var.rg_activation_policy

  disk_size             = var.rg_disk_size
  disk_autoresize       = var.rg_disk_autoresize
  disk_autoresize_limit = var.rg_disk_autoresize_limit
  disk_type             = var.rg_disk_type
  pricing_plan          = var.rg_pricing_plan

  maintenance_window_day          = var.rg_maintenance_window_day
  maintenance_window_hour         = var.rg_maintenance_window_hour
  maintenance_window_update_track = var.rg_maintenance_window_update_track

  database_flags = var.rg_database_flags

  user_labels         = var.rg_user_labels
  enable_default_db   = var.rg_enable_default_db
  enable_default_user = var.rg_enable_default_user
  user_name           = var.rg_user_name
  db_name             = var.rg_db_name

  ip_configuration     = var.rg_ip_configuration
  backup_configuration = var.rg_backup_configuration

  read_replicas   = var.rg_read_replicas
  insights_config = var.rg_insights_config

  depends_on = [module.private-service-access]
}

/******************************************
  Module for Cloud Run
 *****************************************/

module "mum_rg_crun" {
  source = "../../modules/cloudrun"

  service_name          = var.mum_reg_service_name
  project_id            = var.project_id
  location              = var.region
  image                 = var.rg_image
  service_account_email = var.service_account_email
  container_concurrency = var.rg_container_concurrency
  template_annotations  = var.rg_mum_template_annotations
  limits                = var.rg_limits
  ports                 = var.rg_ports
  env_vars              = var.rg_env_vars
  env_secret_vars       = var.rg_env_secret_vars
  template_labels       = var.rg_template_labels
  volumes               = var.rg_volumes
  volume_mounts         = var.rg_volume_mounts

  depends_on = [module.vpc_connector]
}

module "del_rg_crun" {
  source = "../../modules/cloudrun"

  service_name          = var.del_reg_service_name
  project_id            = var.project_id
  location              = var.secondary_location
  image                 = var.rg_image
  service_account_email = var.service_account_email
  container_concurrency = var.rg_container_concurrency
  template_annotations  = var.rg_del_template_annotations
  limits                = var.rg_limits
  ports                 = var.rg_ports
  env_vars              = var.rg_env_vars
  env_secret_vars       = var.rg_env_secret_vars
  template_labels       = var.rg_template_labels
  volumes               = var.rg_volumes
  volume_mounts         = var.rg_volume_mounts

  depends_on = [module.vpc_connector]

}

#######################
## Gateway Service ##
#######################

/******************************************
  Module for Cloud SQL
 *****************************************/

module "gw_pg" {
  source = "../../modules/cloudsql/postgresql"

  project_id           = var.project_id
  region               = var.region
  random_instance_name = false
  name                 = var.gw_pg_sql_name
  database_version     = var.gw_database_version

  deletion_protection = var.gw_deletion_protection
  encryption_key_name = var.gw_encryption_key_name

  // Master configurations
  tier                        = var.gw_tier
  zone                        = var.zone
  availability_type           = var.gw_availability_type
  deletion_protection_enabled = var.gw_deletion_protection_enabled
  activation_policy           = var.gw_activation_policy

  disk_size             = var.gw_disk_size
  disk_autoresize       = var.gw_disk_autoresize
  disk_autoresize_limit = var.gw_disk_autoresize_limit
  disk_type             = var.gw_disk_type
  pricing_plan          = var.gw_pricing_plan

  maintenance_window_day          = var.gw_maintenance_window_day
  maintenance_window_hour         = var.gw_maintenance_window_hour
  maintenance_window_update_track = var.gw_maintenance_window_update_track

  database_flags = var.gw_database_flags

  user_labels         = var.gw_user_labels
  enable_default_db   = var.gw_enable_default_db
  enable_default_user = var.gw_enable_default_user
  user_name           = var.gw_user_name
  db_name             = var.gw_db_name

  ip_configuration     = var.gw_ip_configuration
  backup_configuration = var.gw_backup_configuration

  read_replicas   = var.gw_read_replicas
  insights_config = var.gw_insights_config

  depends_on = [module.private-service-access]
}

/******************************************
  Module for Cloud Run
 *****************************************/

module "mum_gw_crun" {
  source = "../../modules/cloudrun"

  service_name          = var.mum_gw_service_name
  project_id            = var.project_id
  location              = var.region
  image                 = var.gw_image
  service_account_email = var.service_account_email
  container_concurrency = var.gw_container_concurrency
  template_annotations  = var.gw_mum_template_annotations
  limits                = var.gw_limits
  ports                 = var.gw_ports
  env_vars              = var.gw_env_vars
  env_secret_vars       = var.gw_env_secret_vars
  template_labels       = var.gw_template_labels
  volumes               = var.gw_volumes
  volume_mounts         = var.gw_volume_mounts
  argument              = var.gw_argument

  depends_on = [module.vpc_connector]

}

module "del_gw_crun" {
  source = "../../modules/cloudrun"

  service_name          = var.del_gw_service_name
  project_id            = var.project_id
  location              = var.secondary_location
  image                 = var.gw_image
  service_account_email = var.service_account_email
  container_concurrency = var.gw_container_concurrency
  template_annotations  = var.gw_del_template_annotations
  limits                = var.gw_limits
  ports                 = var.gw_ports
  env_vars              = var.gw_env_vars
  env_secret_vars       = var.gw_env_secret_vars
  template_labels       = var.gw_template_labels
  volumes               = var.gw_volumes
  volume_mounts         = var.gw_volume_mounts
  argument              = var.gw_argument

  depends_on = [module.vpc_connector]

}


/******************************************
  Module for Cloud Load balancer
 *****************************************/

resource "google_compute_region_network_endpoint_group" "mum_rg_cloudrun_neg" {
  provider              = google-beta
  name                  = "${var.mum_reg_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = module.mum_rg_crun.service_name
  }
}

resource "google_compute_region_network_endpoint_group" "del_rg_cloudrun_neg" {
  provider              = google-beta
  name                  = "${var.del_reg_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.secondary_location
  cloud_run {
    service = module.del_rg_crun.service_name
  }
}

resource "google_compute_region_network_endpoint_group" "mum_gw_cloudrun_neg" {
  provider              = google-beta
  name                  = "${var.mum_gw_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = module.mum_gw_crun.service_name
  }
}

resource "google_compute_region_network_endpoint_group" "del_gw_cloudrun_neg" {
  provider              = google-beta
  name                  = "${var.del_gw_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.secondary_location

  cloud_run {
    service = module.del_gw_crun.service_name
  }
}

# [START cloudloadbalancing_ext_http_cloudrun]
locals {
  // Backend Services
  services = [
    {
      "service" : module.lb-http.backend_services["${module.mum_gw_crun.service_name}"].self_link,
      "type" : "cloud_run",
      "path" : "/search"
    },
    {
      "service" : module.lb-http.backend_services["${module.mum_gw_crun.service_name}"].self_link,
      "type" : "cloud_run",
      "path" : "/on_search"
    },
    {
      "service" : module.lb-http.backend_services["${module.mum_rg_crun.service_name}"].self_link,
      "type" : "cloud_run",
      "path" : "/lookup"
    },
    {
      "service" : module.lb-http.backend_services["${module.mum_rg_crun.service_name}"].self_link,
      "type" : "cloud_run",
      "path" : "/vlookup"
    },
    {
      "service" : module.lb-http.backend_services["${module.mum_rg_crun.service_name}"].self_link,
      "type" : "cloud_run",
      "path" : "/subscribe"
    },
  ]
}
#disable google managed cert

# resource "google_compute_managed_ssl_certificate" "staging" {
#   provider = google-beta
#   project  = var.project_id
#   name     = "${var.lb_name}-cert"

#   lifecycle {
#     create_before_destroy = true
#   }

#   managed {
#     domains = var.managed_ssl_certificate_domains
#   }
# }

module "lb-http" {
  source = "../../modules/loadbalancer/external_http_lb"

  name    = var.lb_name
  project = var.project_id

  ssl                  = var.ssl
  ssl_certificates     = var.ssl_certificates
  use_ssl_certificates = var.use_ssl_certificates
  https_redirect       = var.ssl
  labels               = var.labels
  address              = var.address
  create_url_map       = false
  url_map              = google_compute_url_map.url-map.self_link

  # Cloud Armor Config
  policy_name                 = var.policy_name
  layer_7_ddos_defense_enable = var.layer_7_ddos_defense_enable
  custom_rules                = var.custom_rules
  backends = {
    "${module.mum_rg_crun.service_name}" = {
      protocol = "HTTPS"

      groups = [
        {
          group = google_compute_region_network_endpoint_group.mum_rg_cloudrun_neg.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }

      log_config = {
        enable = true
      }
    },
    "${module.del_rg_crun.service_name}" = {
      protocol = "HTTPS"

      groups = [
        {
          group = google_compute_region_network_endpoint_group.del_rg_cloudrun_neg.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }

      log_config = {
        enable = false
      }
    },
    "${module.mum_gw_crun.service_name}" = {
      protocol = "HTTPS"

      groups = [
        {
          group = google_compute_region_network_endpoint_group.mum_gw_cloudrun_neg.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }

      log_config = {
        enable = true
      }
    },
    "${module.del_gw_crun.service_name}" = {
      protocol = "HTTPS"

      groups = [
        {
          group = google_compute_region_network_endpoint_group.del_gw_cloudrun_neg.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }

      log_config = {
        enable = false
      }
    }
  }
  #depends_on = [google_compute_managed_ssl_certificate.staging]
}

resource "google_compute_url_map" "url-map" {
  name    = "${var.lb_name}-url-map"
  project = var.project_id

  default_service = module.lb-http.backend_services["${module.mum_rg_crun.service_name}"].self_link

  host_rule {
    hosts        = var.rg_domain_name
    path_matcher = "default"
  }
  path_matcher {
    name            = "default"
    default_service = module.lb-http.backend_services["${module.mum_rg_crun.service_name}"].self_link
  }

  host_rule {
    hosts        = var.gw_domain_name
    path_matcher = "gateway"
  }
  path_matcher {
    name            = "gateway"
    default_service = module.lb-http.backend_services["${module.mum_gw_crun.service_name}"].self_link
  }

  host_rule {
    hosts        = var.old_gw_rg_domain_name
    path_matcher = "oldgwrg"
  }
  path_matcher {
    name            = "oldgwrg"
    default_service = module.lb-http.backend_services["${module.mum_rg_crun.service_name}"].self_link

    dynamic "path_rule" {
      for_each = local.services
      content {
        paths   = [path_rule.value.path]
        service = path_rule.value.service
      }
    }
  }

}

/******************************************
  Module for Compute Engine Resource
 *****************************************/
#commenting elk vm provision for now

# module "elk_vm" {
#   source = "../../modules/compute_engine"

#   name            = var.vmname
#   zone            = var.zone
#   project_id      = var.project_id
#   preemptible     = false
#   service_account = var.service_account
#   tags            = var.tags

#   vmseries_image = var.vmseries_image
#   image_project  = var.image_project
#   machine_type   = var.machine_type
#   disk_size      = var.disk_size

#   subnetwork               = var.vm_subnet_name
#   enable_public_ip_address = false

#   labels = var.labels
# }

# resource "google_compute_disk" "elk-dd-disk" {
#   count = var.data_disk_count
#   name  = "${var.vmname}-${count.index}-disk"
#   type  = var.data_disk_type
#   zone  = var.zone
#   size  = var.data_disk_size
# }

# resource "google_compute_attached_disk" "dd_attach" {
#   count    = var.data_disk_count
#   disk     = google_compute_disk.elk-dd-disk[count.index].id
#   instance = module.elk_vm.id
# }

# Bastion Database VM to Privately Access Cloud SQL.

module "db_vm" {
  source = "../../modules/compute_engine"

  name            = var.db_vmname
  zone            = var.zone
  project_id      = var.project_id
  preemptible     = false
  service_account = var.db_service_account
  tags            = var.db_tags

  # vmseries_image = var.db_vmseries_image
  # image_project  = var.db_image_project
  custom_image = var.db_custom_image
  machine_type = var.db_machine_type
  disk_size    = var.db_disk_size

  subnetwork               = var.db_vm_subnet_name
  enable_public_ip_address = false

  labels = var.db_labels
}
# Tools Management VM to Run Application Utilities.
module "tool_vm" {
  source                   = "../../modules/compute_engine"
  name                     = var.tool_vmname
  zone                     = var.zone
  project_id               = var.project_id
  preemptible              = false
  service_account          = var.tool_service_account
  tags                     = var.tool_tags
  custom_image             = var.tool_custom_image
  machine_type             = var.tool_machine_type
  disk_size                = var.tool_disk_size
  disk_type                = var.tool_disk_type
  subnetwork               = var.tool_vm_subnet_name
  enable_public_ip_address = false
  labels                   = var.tool_labels
  scopes                   = var.tool_scopes
}