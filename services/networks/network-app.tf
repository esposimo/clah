
resource "docker_network" "apps-network" {

    for_each = local.apps-details

    name    = each.value.name
    driver  = "bridge"

    ipam_config {
        gateway = each.value.gateway
        subnet  = each.value.subnet
    }

    internal = false
    labels {
        label = "name"
        value = each.value.name
    }
    labels {
        label = "uuid"
        value = each.value.uuid
    }
    labels {
        label = "env"
        value = var.env
    }
    labels {
        label = "env-uuid"
        value = local.env-uuid
    }
    labels {
        label = "type"
        value = "app"
    }
}