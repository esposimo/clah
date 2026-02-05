output "networks-list" {
  value         = local.out_module
  description   = "Aggregated object containing all resolved network information for the environment"
}

output "list-uuid" {
  value         = local.out_module.list-uuid
  description   = "Network UUIDs grouped by type (provider and application networks)"
}

output "list-names" {
  value         = local.out_module.list-names
  description   = "Network names grouped by type (provider and application networks)"
}

output "list-by-name" {
  value         = local.out_module.list-by-name
  description   = "Bidirectional mapping of network names to UUIDs, grouped by type"
}

output "list-by-uuid" {
  value         = local.out_module.list-by-uuid
  description   = "Bidirectional mapping of network UUIDs to names, grouped by type"
}