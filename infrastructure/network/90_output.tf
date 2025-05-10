output "docker-host-ip" {
  value       = data.external.docker_host_ip.result["docker_host_ip"]
  description = "Docker host ip"
}

output "network-infra-name" {
    value = var.network-infra-name
    description = "Network name"
}