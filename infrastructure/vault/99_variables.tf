# network

variable "storage-engine-address-v4" {
    type = string
    description = "IPv4 address for storage engine container"
}

variable "storage-engine-ports" {
  type = list(object({
    container = number
    host      = number
    protocol  = string
  }))
}

variable "vault-address-v4" {
    type = string
    description = "IPv4 address for vault container"
}

variable "vault-ports" {
  type = list(object({
    container = number
    host      = number
    protocol  = string
  }))
}

# storage engine vars

variable "storage-engine-image-name" {
    type = string
    description = "Image for storage engine's vault"
}

variable "storage-engine-image-version" {
    type = string
    description = "Version image"
}

variable "storage-engine-volume" {
    type = string
    description = "Volume name for storage engine container"
}

variable "storage-engine-container" {
    type = string
    description = "Container name for storage engine"
}

variable "vault-image-name" {
    type = string
    description = "Image for vault"
}

variable "vault-image-version" {
    type = string
    description = "Version image"
}

variable "vault-volume" {
    type = string
    description = "Volume name for vault container"
}

variable "vault-container-name" {
    type = string
    description = "Container name for vault"
}