storage-engine-image-name       = "hashicorp/consul"
storage-engine-image-version    = "1.20"
storage-engine-volume           = "clah-vol-storage-engine-vault"
storage-engine-container        = "clah-storage-engine-vault"
storage-engine-ports = [
    { container = 8300, host = 15300, protocol = "tcp" },
    { container = 8301, host = 15301, protocol = "tcp" },
    { container = 8301, host = 15301, protocol = "udp" },
    { container = 8302, host = 15302, protocol = "tcp" },
    { container = 8302, host = 15302, protocol = "udp" },
    { container = 8500, host = 15500, protocol = "tcp" },
    { container = 8600, host = 15600, protocol = "tcp" },
    { container = 8600, host = 15600, protocol = "udp" }
]

vault-image-name        = "hashicorp/vault"
vault-image-version     = "1.19"
vault-volume            = "vol-vault"
vault-container-name    = "clah-vault"
vault-ports = [
    { container = 8200, host = 28200, protocol = "tcp" }
]

vault-cert = {
    common-name       = "vault.local"
    country           = "IT"
    province          = "Italy"
    locality          = "Naples"
    organization      = "Vault Inc"
    dns-names         = [ "docker-host" ]
}

destroy-volumes-on-delete       = false
publish-storage-engine-ports    = false
publish-vault-ports             = false