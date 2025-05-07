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

provider "vaultoperator" {
  # example configuration here
  vault_addr        = "https://${var.vault-address-v4}:8200"
  vault_skip_verify = true  
}
