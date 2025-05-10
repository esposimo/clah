terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.3.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.21.0"
    }
   vaultoperator = {
     source  = "rickardgranberg/vaultoperator"
     version = "0.1.11"
   }
  http = {
    source  = "hashicorp/http"
    version = "3.5.0"
  }
  null = {
    source = "hashicorp/null"
    version = "3.2.4"
   }
  vault = {
    source = "hashicorp/vault"
    version = "4.8.0"
   }
  }
  backend "consul" { }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "consul" {
  address    = "127.0.0.1:15080"
  datacenter = "hsh-dc"
}

data "consul_keys" "docker-host-ip" {
  # Read the launch AMI from Consul
  key {
    name    = "docker-host-ip"
    path    = "infrastructure/network/docker-host-ip"
  }
}

data "consul_keys" "infrastructure_network" {
  # Read the launch AMI from Consul
  key {
    name    = "infra-net"
    path    = "infrastructure/network/name"
  }
}

provider "vaultoperator" {
  # example configuration here
  vault_addr        = "https://${var.vault-address-v4}:8200"
  vault_skip_verify = true
}
#
provider "vault" {
 address         = "https://${var.vault-address-v4}:8200"
 token           = vaultoperator_init.vault_bootstrap.root_token
 skip_tls_verify = true
}
