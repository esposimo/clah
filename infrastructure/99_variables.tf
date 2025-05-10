# network vars 
variable "network-infra-name" {
    type        = string
    description = "Network name for infrastructure services"
}

variable "network-infra-gateway" {
    type        = string
    description = "Gateway for infrastracture network"
}

variable "network-infra-subnet" {
    type        = string
    description = "CIDR block that defines the IP address range for the infrastructure network. Suggest a /24"
}

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

variable "elastic-master-address-v4" {
    type = string
    description = "IPv4 address for elastic master node"
}

variable "elastic-cold-address-v4" {
    type = string
    description = "IPv4 address for elastic cold node"
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

# elastic variable 

variable "elastic-image-name" {
    type = string
    description = "Image for elastic container"
}

variable "elastic-image-version" {
    type = string
    description = "Image version"
}

variable "elastic-master-container-name" {
    type = string
    description = "Container name for elastic master"
}

variable "elastic-master-data-volume" {
    type = string 
    description = "Volume name for elastic master"
}

variable "elastic-master-env-variable" {
    type = set(string)
    description = "List of environment to inject in container"
    default = []
}

variable "elastic-cold-container-name" {
    type = string
    description = "Container name for elastic cold"
}

variable "elastic-cold-data-volume" {
    type = string 
    description = "Volume name for elastic cold"
}

variable "elastic-cold-env-variable" {
    type = set(string)
    description = "List of environment to inject in container"
    default = []
}

variable "elastic-master-ports" {
  type = list(object({
    container = number
    host      = number
    protocol  = string
  }))
}

#elastic-master-address-v4
#elastic-master-image-name
#elastic-master-image-version
#elastic-master-container-name
#elastic-maseter-bind-mount
#elastic-master-env-variable