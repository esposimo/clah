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
  }
  backend "consul" { }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "consul" {
  address    = var.SC_ENDPOINT
  datacenter = "hsh-dc"
}