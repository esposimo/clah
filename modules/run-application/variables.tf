variable "env" {
  type        = string
  description = "Logical environment name used to resolve environment and networks from Consul"
}

variable "application_network_name" {
  type        = string
  description = "Application network name that every container must join"
}

variable "attach_infrastructure_network" {
  type        = bool
  description = "When true, all containers are attached to the provider network"
  default     = false
}

variable "containers_spec_file" {
  type        = string
  description = "Path to a JSON file describing containers to deploy"
}
