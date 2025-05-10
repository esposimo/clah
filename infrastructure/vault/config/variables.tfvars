storage-engine-image-name       = "hashicorp/consul"
storage-engine-image-version    = "1.20"
storage-engine-volume           = "vol-storage-engine-vault"
storage-engine-container        = "clah-storage-engine-vault"
storage-engine-address-v4       = "10.190.10.2"
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
vault-address-v4        = "10.190.10.3"
vault-ports = [
    { container = 8200, host = 28200, protocol = "tcp" }
]