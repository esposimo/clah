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
  }
  backend "consul" {
    path    = "tf-state/infrastructure/networks"
  }
}
provider "consul" {
  datacenter = "hsh-dc"
}


