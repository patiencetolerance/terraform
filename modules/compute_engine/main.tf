data "google_compute_image" "vmseries" {
  count = var.custom_image == null ? 1 : 0

  family  = var.vmseries_image
  project = var.image_project
}

resource "google_compute_address" "private" {
  name         = "${var.name}-private"
  address_type = "INTERNAL"
  address      = var.private_address
  subnetwork   = var.subnetwork
  region       = var.region
}

resource "google_compute_address" "public" {
  count = var.enable_public_ip_address == true ? 1 : 0

  name         = "${var.name}-public"
  address_type = "EXTERNAL"
  region       = var.region
}

locals {
  network_interface = length(format("%s%s", var.network, var.subnetwork)) == 0 ? [] : [1]
}


resource "google_compute_instance" "this" {
  name                      = var.name
  zone                      = var.zone
  machine_type              = var.machine_type
  labels                    = var.labels
  tags                      = var.tags
  metadata_startup_script   = var.metadata_startup_script
  project                   = var.project_id
  resource_policies         = var.resource_policies
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = merge({
    serial-port-enable = true
    ssh-keys           = var.ssh_keys
    },
    var.bootstrap_options,
    var.metadata
  )

  service_account {
    email  = var.service_account
    scopes = var.scopes
  }

  dynamic "network_interface" {
    for_each = local.network_interface

    content {
      network_ip = var.private_address
      network    = var.network
      subnetwork = var.subnetwork

      dynamic "access_config" {
        for_each = var.enable_public_ip_address == true ? [1] : []
        content {
          nat_ip       = google_compute_address.public.address
          network_tier = "PREMIUM"
        }
      }

      dynamic "alias_ip_range" {
        for_each = var.alias_ip_ranges
        content {
          ip_cidr_range         = alias_ip_range.value.ip_cidr_range
          subnetwork_range_name = alias_ip_range.value.subnetwork_range_name
        }
      }
    }
  }

  boot_disk {
    initialize_params {
      image = coalesce(var.custom_image, try(data.google_compute_image.vmseries[0].self_link, null))
      type  = var.disk_type
      size  = var.disk_size
    }
  }

  scheduling {
    preemptible        = var.preemptible
    automatic_restart  = var.preemptible == true ? false : true
    provisioning_model = var.preemptible == true ? "SPOT" : "STANDARD"
  }
}