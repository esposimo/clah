resource "docker_image" "build_storage_engine" {
  name         = "${var.storage-engine-image-name}:${var.storage-engine-image-version}"
  force_remove = false
  keep_locally = var.destroy-volumes-on-delete
}

resource "docker_volume" "volume_storage_engine" {
    name   = "${var.storage-engine-volume}"
    driver = "local"
}

resource "docker_container" "storage_engine_vault" {
  depends_on    = [ docker_image.build_storage_engine , docker_volume.volume_storage_engine ]
  rm            = false

  name          = "${var.storage-engine-container}"
  image         = docker_image.build_storage_engine.image_id

  networks_advanced {
    name          = data.consul_keys.network_provider.var.name
  }

  lifecycle {
    ignore_changes = [ 
      log_opts, log_driver
     ]
  }

  volumes {
      container_path = "/consul/data"
      volume_name    = docker_volume.volume_storage_engine.name
  }
  volumes {
      container_path = "/etc/timezone"
      volume_name    = "/etc/timezone"
  }
  volumes {
      container_path = "/etc/localtime"
      volume_name    = "/etc/localtime"
  }

 dynamic "ports" {
    for_each = var.storage-engine-ports
    content {
        internal = ports.value.container
        external = ports.value.host
        protocol = ports.value.protocol
    }
  }

  publish_all_ports = var.publish-storage-engine-ports
  restart = "always"
}

resource "consul_keys" "storage_engine_vault" {

  key {
    path    = "infrastructure/vault/storage-engine/ipv4-address"
    value   = local.storage_engine_vault_ipaddress
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/storage-engine/gui-container-port"
    value   = 8500
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/storage-engine/gui-host-port"
    value   = local.storage_engine_vault_gui_host_port
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/storage-engine/endpoint-container"
    value   = local.storage_engine_endpoint_container
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/storage-engine/endpoint-host"
    value   = local.storage_engine_endpoint_host
    delete  = true 
  }
}
