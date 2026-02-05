variable "storage-engine-image-name" {
    type            = string
    default         = "hashicorp/consul"
    description     = "Image for storage engine's vault"
}
variable "storage-engine-image-version" {
    type            = string
    default         = "1.20"
    description     = "Version image"
}
variable "storage-engine-volume" {
    type            = string
    default         = "clah-vol-storage-engine-vault"
    description     = "Volume name for storage engine container"
}
variable "storage-engine-container" {
    type            = string
    default         = "clah-storage-engine-vault"
    description     = "Container name for storage engine"
}
variable "storage-engine-ports" {
  type = list(object({
    container       = number
    host            = number
    protocol        = string
  }))
  description       = "Ports mapping for storage engine container"
}


variable "vault-image-name" {
    type            = string
    default         = "hashicorp/vault"
    description     = "Image for vault"
}

variable "vault-image-version" {
    type            = string
    default         = "1.19"
    description     = "Version image"
}

variable "vault-ports" {
  type = list(object({
    container       = number
    host            = number
    protocol        = string
  }))
   description      = "Ports mapping for vault container"
}
variable "vault-cert" {
    type = object({
        common-name       = string
        country           = string
        province          = string
        locality          = string
        organization      = string
        dns-names         = list(string)
    })
    description     = "Certificates configuration for vault service"
    default = {
      common-name   = "vault.local"
      country       = "IT"
      province      = "Italy"
      locality      = "Naples"
      organization  = "Vault Inc"
      dns-names     = []
    } 
}

variable "vault-volume" {
    type            = string
    default         = "vol-vault"
    description     = "Volume name for vault container"
}

variable "vault-container-name" {
    type            = string
    default         = "clah-vault"
    description     = "Container name for vault"
}

variable "destroy-volumes-on-delete" {
    type            = bool
    default         = false
    description     = "If true, volumes will be destroyed when the container is destroyed"
}

variable "publish-storage-engine-ports" {
    type            = bool
    default         = true
    description     = "If true, storage engine ports will be published"
}

variable "publish-vault-ports" {
    type            = bool
    default         = true
    description     = "If true, vault ports will be published"
}