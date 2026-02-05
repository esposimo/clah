
resource "docker_network" "provider-network" {

    name = local.provider-network-name
    driver = "bridge"

    ipam_config {
        gateway = local.provider-network-gateway
        subnet = local.provider-network-subnet
    }

    internal = false
    labels {
        label = "name"
        value = local.networks-registry.list-names.provider
    }
    labels {
        label = "uuid"
        value = local.provider-network-uuid
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
        value = "provider"
    }
}