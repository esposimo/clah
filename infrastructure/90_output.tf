output "docker-host-ip" {
  value       = local.external-ip
  description = "Docker host ip"
}

output "internal-storage-engine-ip" {
    value = var.storage-engine-address-v4
    description = "Storage engine container ip"
}

output "internal-storage-engine-port" {
    value = "8500"
    description = "Storage engine container port"
}

output "external-storage-engine-ip" {
    value = local.external-ip
    description = "Storage engine external ip"
}

output "external-storage-engine-port" {
    value = local.external-storage-engine-port
    description = "Storage engine mapped port between docker host and container"
}

output "external-storage-engine-endpoint" {
    value = local.external-storage-engine-endpoint
    description = "Storage engine external endpoint"
}

output "internal-vault-ip" {
    value = var.vault-address-v4
    description = "Vault container ip"
}

output "internal-vault-port" {
    value = "8200"
    description = "Vault container port"
}

output "external-vault-ip" {
    value = local.docker-host-ip
    description = "Vault external ip"
}

output "external-vault-port" {
    value = local.external-vault-port
    description = "Vault mapped port between docker host and container"
}

output "external-vault-endpoint" {
    value = local.external-vault-endpoint
    description = "Vault engine external endpoint"
}

output "internal-elastic-master-ip" {
    value = var.elastic-master-address-v4
    description = "Elastic master container ip"
}

output "internal-elastic-master-port" {
    value = "9200"
    description = "Vault container port"
}

output "external-elastic-master-ip" {
    value = local.docker-host-ip
    description = "Elastic external ip"
}

output "external-elastic-master-port" {
    value = local.external-elastic-master-port
    description = "Elastic mapped port between docker host and container"
}

output "external-elastic-master-endpoint" {
    value = local.external-elastic-master-endpoint
    description = "Elastic engine external endpoint"
}