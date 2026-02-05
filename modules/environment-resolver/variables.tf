variable "env" {
  type        = string
  description = "Logical name of the environment to resolve from Consul"

  validation {
    condition     = length(var.env) > 0
    error_message = "Environment name must not be empty."
  }
}