resource "docker_network" "infrastructure_network" {

  name        = var.network-infra-name
  attachable  = true
  driver      = "bridge"
  ingress     = false
  
  ipam_config {
    subnet    = var.network-infra-subnet
    gateway   = var.network-infra-gateway
  }
}

data "external" "docker_host_ip" {
  program = ["${path.cwd}/../../bin/get_docker_ip.sh"]
}

resource "consul_keys" "infrastructure_network_info" {
  depends_on = [ docker_network.infrastructure_network ]
  
  key {
    path  = "infrastructure/network/name"
    value = var.network-infra-name
  }
  key {
    path  = "infrastructure/network/subnet"
    value = var.network-infra-subnet
  }
  key {
    path  = "infrastructure/network/gateway"
    value = var.network-infra-gateway
  }
  key {
    path = "infrastructure/network/docker-host-ip"
    value = data.external.docker_host_ip.result["docker_host_ip"]
  }
}