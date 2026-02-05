data "consul_keys" "list-env-by-name" {

  # Prefix to add to prepend to all of the subkey names below.
  key {
    name    = "list"
    path    = "environments/list-by-name"
  }
}

module "get-env-uid" {
  source = "../environment-resolver"

  env = var.env
}


data "consul_keys" "networks-list" {

  key {
    name    = "provider"
    path    = "indexes/networks/by-type/${local.env_uuid}/provider"
  }

  key {
    name    = "apps"
    path    = "indexes/networks/by-type/${local.env_uuid}/app"
  }

}

data "consul_keys" "network-provider" {
  
  key {
    name = "provider-network"
    path = "networks/${local.env_uuid}/${local.provider_network_uuid}/name"
  }

}

data "consul_keys" "networks-apps" {
  for_each = toset(local.app_network_uuids)

  key {
    name = "app-network"
    path = "networks/${local.env_uuid}/${each.key}/name"
  }

}

data "consul_key_prefix" "fetch_provider" {
    path_prefix = "networks/${local.env_uuid}/${local.provider_network_uuid}/"

    subkey {
      name    = "name"
      path    = "name"
    }

    subkey {
      name    = "subnet"
      path    = "subnet"
    }

    subkey {
      name    = "gateway"
      path    = "gateway"
    }

    subkey {
      name    = "type"
      path    = "type"
    }

    subkey {
      name    = "description"
      path    = "description"
    }
    
    subkey {
      name    = "created"
      path    = "created_at"
    }
}

data "consul_key_prefix" "fetch_apps" {
    for_each    = toset(local.app_network_uuids)
    path_prefix = "networks/${local.env_uuid}/${each.key}/"

    subkey {
      name    = "name"
      path    = "name"
    }

    subkey {
      name    = "subnet"
      path    = "subnet"
    }

    subkey {
      name    = "gateway"
      path    = "gateway"
    }

    subkey {
      name    = "type"
      path    = "type"
    }

    subkey {
      name    = "description"
      path    = "description"
    }
    
    subkey {
      name    = "created"
      path    = "created_at"
    }
}

locals {

  env_uuid                = module.get-env-uid.env_uuid
  provider_network_uuid   = data.consul_keys.networks-list.var.provider
  app_network_uuids       = jsondecode(data.consul_keys.networks-list.var.apps)

  provider_map            = { (data.consul_keys.network-provider.var.provider-network) = local.provider_network_uuid }
  apps_list = [
    for _, v in data.consul_keys.networks-apps :
    v.var.app-network
  ]
  apps_map = {
    for net_uuid, d in data.consul_keys.networks-apps :
    d.var.app-network => net_uuid
  }
  apps_map_inverted = {
    for net_uuid, d in data.consul_keys.networks-apps :
    net_uuid => d.var.app-network
  }
  appsbyname = { 
      for net_uuid, d in data.consul_key_prefix.fetch_apps : 
      (net_uuid) => 
      { 
        name          = d.var.name
        subnet        = d.var.subnet
        gateway       = d.var.gateway
        type          = d.var.type
        description   = d.var.description
        created       = d.var.created
      } 
  }
  providername = {
          (local.provider_network_uuid) = {
            name          = data.consul_key_prefix.fetch_provider.var.name
            subnet        = data.consul_key_prefix.fetch_provider.var.subnet
            gateway       = data.consul_key_prefix.fetch_provider.var.gateway
            type          = data.consul_key_prefix.fetch_provider.var.type
            description   = data.consul_key_prefix.fetch_provider.var.description
            created       = data.consul_key_prefix.fetch_provider.var.created
          }
  }
  out_module = {
        list-uuid = {
            provider = local.provider_network_uuid
            apps     = local.app_network_uuids
        }
        list-names = {
            provider = data.consul_keys.network-provider.var.provider-network
            apps     = local.apps_list
        }
        list-by-name = {
            provider  = local.provider_map
            apps      = local.apps_map
        }
        list-by-uuid = {
            provider = { (local.provider_network_uuid) = data.consul_keys.network-provider.var.provider-network }
            apps     = local.apps_map_inverted
        }
        details = merge(local.providername,local.appsbyname)
  }
}




