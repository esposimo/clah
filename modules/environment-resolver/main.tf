data "consul_keys" "list-env-by-name" {

  # Prefix to add to prepend to all of the subkey names below.
  key {
    name    = "list"
    path    = "environments/list-by-name"
  }
}

locals {
  environment = jsondecode(data.consul_keys.list-env-by-name.var.list)
  env_uuid    = local.environment[var.env].uuid
}