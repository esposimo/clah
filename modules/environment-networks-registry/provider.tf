terraform {
  required_version = ">= 1.11.0"

  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.22.1"
    }
  }
}