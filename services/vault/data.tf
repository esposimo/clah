data "consul_keys" "network_provider" {

  # Prefix to add to prepend to all of the subkey names below.
  key {
    name    = "name"
    path    = "infrastructure/networks/provider/name"
  }
  key {
    name    = "subnet"
    path    = "infrastructure/networks/provider/subnet"
  }
  key {
    name    = "gateway"
    path    = "infrastructure/networks/provider/gateway"
  }
  key {
    name    = "driver"
    path    = "infrastructure/networks/provider/driver"
  }
  key {
    name    = "docker-host"
    path    = "infrastructure/docker-host"
  }
}
