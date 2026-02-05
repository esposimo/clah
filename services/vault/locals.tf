
locals {
  storage_engine_vault_ipaddress        = docker_container.storage_engine_vault.network_data[0].ip_address
  storage_engine_vault_gui_host_port    = flatten([ for p in var.storage-engine-ports : p.host if p.container == 8500 && p.protocol == "tcp" ])[0]
  storage_engine_endpoint_container     = "http://${docker_container.storage_engine_vault.network_data[0].ip_address}:8500"
  storage_engine_endpoint_host          = "http://${local.docker-host}:${local.storage_engine_vault_gui_host_port}"

  vault_ipv4_address                    = docker_container.vault_container.network_data[0].ip_address
  vault_gui_host_port                   = flatten([ for p in var.vault-ports : p.host if p.container == 8200 && p.protocol == "tcp" ])[0]
  vault_endpoint_container              = "https://${docker_container.vault_container.network_data[0].ip_address}:8200/"
  vault_endpoint_host                   = "https://${local.docker-host}:${local.vault_gui_host_port}"

  docker-host                           = data.consul_keys.network_provider.var.docker-host
  certs = {
    vault = {
        cert-file         = "/vault/certs/vault.crt"
        key-file          = "/vault/certs/vault.key"
        common-name       = "vault.local"
        country           = "IT"
        province          = "Italy"
        locality          = "Naples"
        organization      = "Vault Inc"
        dns-names         = [
            local.docker-host
        ]
    }
  }
}