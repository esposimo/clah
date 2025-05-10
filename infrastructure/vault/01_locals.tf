locals {

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
            var.vault-address-v4,
            data.consul_keys.docker-host-ip.var.docker-host-ip
        ]
    }
  }

  external-ip                       = data.consul_keys.docker-host-ip.var.docker-host-ip
  docker-host-ip                    = data.consul_keys.docker-host-ip.var.docker-host-ip
  
  internal-storage-engine-ip        = var.storage-engine-address-v4
  internal-storage-engine-port      = "8500"
  external-storage-engine-ip        = local.docker-host-ip
  external-storage-engine-port      = flatten([ for p in var.storage-engine-ports : p.host if p.container == 8500 && p.protocol == "tcp" ])[0]
  external-storage-engine-endpoint  = "http://${local.docker-host-ip}:${local.external-storage-engine-port}"

  internal-vault-ip         = var.vault-address-v4
  internal-vault-port       = "8200"
  external-vault-ip         = local.docker-host-ip
  external-vault-port       = flatten([ for p in var.vault-ports : p.host if p.container == 8200 && p.protocol == "tcp" ])[0]
  external-vault-endpoint   = "https://${local.docker-host-ip}:${local.external-vault-port}"

}