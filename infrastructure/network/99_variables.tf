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