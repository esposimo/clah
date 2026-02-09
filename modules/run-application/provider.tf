terraform {
  required_version = ">= 1.11.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.22.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}
