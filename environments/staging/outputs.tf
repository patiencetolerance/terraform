# /*****************************************************
#   Outputs of VPC Resources
#  *****************************************************/

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}

output "subnets_names" {
  value       = [for network in module.subnets.subnets : network.name]
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = [for network in module.subnets.subnets : network.ip_cidr_range]
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_regions" {
  value       = [for network in module.subnets.subnets : network.region]
  description = "The region where the subnets will be created"
}

# /*****************************************************
#   Outputs of Cloud NAT Resources
#  *****************************************************/

output "cloud_nat_name" {
  description = "Name of the Cloud NAT"
  value       = module.cloud-nat.name
}

output "addresses" {
  description = "List of address values managed by this module (e.g. [\"1.2.3.4\"])"
  value       = google_compute_address.address.*.address
}

# /*****************************************************
#   Outputs of Private Service Access Resources
#  *****************************************************/

output "reserved_range_name" {
  description = "The Global Address resource name"
  value       = module.private-service-access.google_compute_global_address_name
}

output "reserved_range_address" {
  description = "The Global Address resource name"
  value       = module.private-service-access.address
}

# /*****************************************************
#   Outputs of Cloud SQL Resources
#  *****************************************************/

output "rg_master_instance_ip_address" {
  value = module.rg_pg.instance_ip_address
}

output "gw_master_instance_ip_address" {
  value = module.gw_pg.instance_ip_address
}

# /*****************************************************
#   Outputs of Static IP Resources
#  *****************************************************/

# output "gke-lb-ip" {
#   description = "Global IP address fot LB"
#   value       = module.gke-lb-ip.address
# }