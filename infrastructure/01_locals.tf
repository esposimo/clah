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
            data.external.docker_host_ip.result["docker_host_ip"]
        ]
    }
    kibana = {
        cert-file         = "elastic.crt"
        key-file          = "/vault/certs/vault.key"
        common-name       = "vault.local"
        country           = "IT"
        province          = "Italy"
        locality          = "Naples"
        organization      = "Vault Inc"
        dns-names         = [
            var.elastic-master-address-v4,
            data.external.docker_host_ip.result["docker_host_ip"]
        ]
    }
  }

  external-ip                       = data.external.docker_host_ip.result["docker_host_ip"]
  docker-host-ip                    = data.external.docker_host_ip.result["docker_host_ip"]
  
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


  internal-elastic-master-ip = var.elastic-master-address-v4
  internal-elastic-master-port = "9200"
  external-elastic-master-ip = local.docker-host-ip
  external-elastic-master-port = flatten([ for p in var.elastic-master-ports : p.host if p.container == 9200 && p.protocol == "tcp" ])[0]
  external-elastic-master-endpoint = "https://${local.docker-host-ip}:${local.external-elastic-master-port}"

  internal-elastic-cold-ip = var.elastic-cold-address-v4
  internal-elastic-cold-port = "9200"

}