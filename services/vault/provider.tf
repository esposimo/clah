terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.22.1"
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
  backend "consul" {
    path    = "tf-state/infrastructure/vault"
  }
}

provider "consul" {
  datacenter = "hsh-dc"
}
