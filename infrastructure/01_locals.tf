locals {
 
  certs = {
    cert_file         = "/vault/certs/vault.crt"
    key_file          = "/vault/certs/vault.key"
    common_name       = "vault.local"
    country           = "IT"
    province          = "Italy"
    locality          = "Naples"
    organization      = "Vault Inc"
    dns_names         = [
      var.vault-address-v4,
      data.external.docker_host_ip.result["docker_host_ip"]
    ]
  }

  external_ip                       = data.external.docker_host_ip.result["docker_host_ip"]
  external_storage_engine_port      = flatten([ for p in var.storage-engine-ports : p.host if p.container == 8500 && p.protocol == "tcp" ])[0]
  external_storage_engine_endpoint  = "http://${local.external_ip}:${local.external_storage_engine_port}"

  external_vault_port       = flatten([ for p in var.vault-ports : p.host if p.container == 8200 && p.protocol == "tcp" ])[0]
  external_vault_endpoint   = "https://${local.external_ip}:${local.external_vault_port}"

}