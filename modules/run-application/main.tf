module "environment" {
  source = "../environment-resolver"
  env    = var.env
}

module "environment_networks" {
  source = "../environment-networks-registry"
  env    = var.env
}

locals {
  raw_containers = jsondecode(file(var.containers_spec_file))

  containers = {
    for container in local.raw_containers :
    container.name => merge(container, {
      networks           = distinct(concat([var.application_network_name], try(container.networks, [])))
      attach_on_provider = try(container.attach_on_provider, false)
      ports              = try(container.ports, [])
      mounts             = try(container.mounts, [])
      volumes            = try(container.volumes, [])
      devices            = try(container.devices, [])
      environment_vars   = try(container.var.environment, {})
      build              = try(container.build, null)
    })
  }

  app_network_uuid_by_name = module.environment_networks["list-by-name"].apps
  app_networks_by_name = {
    for net_uuid, net_name in module.environment_networks["list-by-uuid"].apps :
    net_name => {
      uuid = net_uuid
      name = net_name
    }
  }

  selected_app_networks_by_container = {
    for container_name, container in local.containers :
    container_name => {
      for network_name in container.networks :
      network_name => local.app_networks_by_name[network_name]
      if contains(keys(local.app_networks_by_name), network_name)
    }
  }

  invalid_networks_by_container = {
    for container_name, container in local.containers :
    container_name => [
      for network_name in container.networks : network_name
      if !contains(keys(local.app_networks_by_name), network_name)
    ]
  }

  invalid_networks = distinct(flatten(values(local.invalid_networks_by_container)))

  build_containers = {
    for container_name, container in local.containers :
    container_name => container
    if container.build != null
  }

  managed_volumes = {
    for volume in flatten([
      for container_name, container in local.containers : [
        for volume in container.volumes : {
          key                 = "${container_name}::${volume.name}"
          container_name      = container_name
          name                = volume.name
          path                = volume.path
          destroy_on_recreate = try(volume.destroy_on_recreate, false)
        }
      ]
    ]) : volume.key => volume
  }

  container_networks_with_provider = {
    for container_name, container in local.containers :
    container_name => concat(
      [for _, net in local.selected_app_networks_by_container[container_name] : net.name],
      (var.attach_infrastructure_network || container.attach_on_provider)
      ? [module.environment_networks["list-by-uuid"].provider[module.environment_networks["list-uuid"].provider]]
      : []
    )
  }

  container_env = {
    for container_name, container in local.containers :
    container_name => [
      for key, value in container.environment_vars : "${key}=${value}"
    ]
  }
}

resource "random_uuid" "application" {}

resource "random_uuid" "container" {
  for_each = local.containers
}

resource "docker_image" "built" {
  for_each = local.build_containers

  name = each.value.image

  build {
    context    = each.value.build.context
    dockerfile = each.value.build.file
  }
}

resource "docker_volume" "managed" {
  for_each = local.managed_volumes

  name          = each.value.name
  driver        = "local"
  force_destroy = each.value.destroy_on_recreate
}

resource "docker_container" "this" {
  for_each = local.containers

  name  = each.value.name
  image = contains(keys(docker_image.built), each.key) ? docker_image.built[each.key].image_id : each.value.image

  dynamic "networks_advanced" {
    for_each = toset(local.container_networks_with_provider[each.key])
    content {
      name = networks_advanced.value
    }
  }

  dynamic "ports" {
    for_each = each.value.ports
    content {
      internal = tonumber(ports.value.container)
      external = tonumber(ports.value.host)
      protocol = ports.value.protocol
    }
  }

  dynamic "volumes" {
    for_each = each.value.mounts
    content {
      host_path      = keys(volumes.value)[0]
      container_path = values(volumes.value)[0]
    }
  }

  dynamic "volumes" {
    for_each = each.value.volumes
    content {
      volume_name    = docker_volume.managed["${each.key}::${volumes.value.name}"].name
      container_path = volumes.value.path
    }
  }

  dynamic "devices" {
    for_each = each.value.devices
    content {
      host_path      = devices.value.name
      container_path = devices.value.path
    }
  }

  env = local.container_env[each.key]

  lifecycle {
    precondition {
      condition     = length(local.invalid_networks) == 0
      error_message = "One or more requested app networks are not part of environment '${var.env}': ${join(", ", local.invalid_networks)}"
    }
  }
}

locals {
  container_network_ip_by_uuid = {
    for container_name, container in docker_container.this :
    container_name => merge(
      {
        for network in container.network_data :
        lookup(local.app_network_uuid_by_name, network.network_name, "") => network.ip_address
        if contains(keys(local.app_network_uuid_by_name), network.network_name)
      },
      {
        for network in container.network_data :
        module.environment_networks["list-uuid"].provider => network.ip_address
        if network.network_name == module.environment_networks["list-by-uuid"].provider[module.environment_networks["list-uuid"].provider]
      }
    )
  }

  container_consul_entries = {
    for container_name, container in local.containers :
    container_name => merge(
      {
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/name"  = container.name
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/image" = container.image
      },
      container.build != null ? {
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/context-path" = container.build.context
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/Dockerfile"   = file("${container.build.context}/${container.build.file}")
      } : {},
      {
        for network_uuid, ip in local.container_network_ip_by_uuid[container_name] :
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/networks/${network_uuid}/ip" => ip
      },
      {
        for network_uuid, _ in local.container_network_ip_by_uuid[container_name] :
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/networks/${network_uuid}/port-map" => jsonencode(container.ports)
      },
      {
        for volume in container.volumes :
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/volumes/${volume.name}" => volume.path
      },
      {
        for device in container.devices :
        "applications/${module.environment.env_uuid}/${random_uuid.application.result}/${random_uuid.container[container_name].result}/devices/${device.name}" => device.path
      }
    )
  }
}

resource "consul_keys" "application_registry" {
  for_each = local.container_consul_entries

  dynamic "key" {
    for_each = each.value
    content {
      path   = key.key
      value  = key.value
      delete = true
    }
  }
}
