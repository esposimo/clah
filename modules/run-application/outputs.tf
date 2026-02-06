output "env_uuid" {
  description = "Resolved UUID of the target environment"
  value       = module.environment.env_uuid
}

output "application_uuid" {
  description = "Stable UUID representing the deployed container stack"
  value       = random_uuid.application.result
}

output "container_uuids" {
  description = "Stable UUIDs generated for each container"
  value = {
    for container_name, container_uuid in random_uuid.container :
    container_name => container_uuid.result
  }
}

output "provider_network_uuid" {
  description = "UUID of the provider network for the environment"
  value       = module.environment_networks["list-uuid"].provider
}

output "app_network_uuids" {
  description = "UUID map of application networks resolved by name"
  value       = module.environment_networks["list-by-name"].apps
}

output "container_ips_by_network_uuid" {
  description = "Container IP addresses indexed by network UUID"
  value       = local.container_network_ip_by_uuid
}
