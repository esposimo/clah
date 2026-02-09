# fetch uuid by name
module "env-networks-registry" {
    source  = "../../modules/environment-networks-registry"
    env     = "${var.env}"
}

module "environment-resolver" {
    source  = "../../modules/environment-resolver"
    env     = "${var.env}"
}

locals {
    env                             = var.env
    env-uuid                        = module.environment-resolver.env_uuid
    networks-registry               = module.env-networks-registry.networks-list

    provider-network-name           = "${local.networks-registry.list-names.provider}"
    provider-network-uuid           = local.networks-registry.list-uuid.provider
    provider-network-subnet         = local.networks-registry.details[local.provider-network-uuid].subnet
    provider-network-gateway        = local.networks-registry.details[local.provider-network-uuid].gateway

    apps-networks-name = module.env-networks-registry.networks-list.list-by-name.apps
    apps-details = {
        for name, uuid in local.networks-registry.list-by-name.apps :
        uuid => {
            name      = "${name}"
            uuid      = uuid
            subnet    = local.networks-registry.details[uuid].subnet
            gateway   = local.networks-registry.details[uuid].gateway
            env       = var.env
            env_uuid  = local.env-uuid
        }
    }
}

