terraform {
  required_version = ">= 1.11.0"

  required_providers {
    docker = {
      source  = "cybershard/docker"
      version = "1.0.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}
