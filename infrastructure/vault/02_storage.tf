resource "docker_image" "build_storage_engine" {
  name         = "${var.storage-engine-image-name}:${var.storage-engine-image-version}"
  force_remove = false
  keep_locally = false
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
    name          = data.consul_keys.infrastructure_network.var.infra-net
    ipv4_address  = var.storage-engine-address-v4
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
}

resource "consul_keys" "storage_engine_service_config" {
  depends_on = [ docker_container.storage_engine_vault, data.consul_keys.docker-host-ip ]
  
  key {
    path  = "infrastructure/storage-engine/container-name"
    value = var.storage-engine-container
  }
  key {
    path  = "infrastructure/storage-engine/build-image"
    value = "${var.storage-engine-image-name}:${var.storage-engine-image-version}"
  }
  key {
    path  = "infrastructure/storage-engine/internal-ip"
    value = var.storage-engine-address-v4
  }
  key {
    path  = "infrastructure/storage-engine/internal-port"
    value = "8500"
  }
  key {
    path  = "infrastructure/storage-engine/internal-endpoint"
    value = "http://${var.storage-engine-address-v4}:8500/"
  }
  key {
    path  = "infrastructure/storage-engine/external-ip"
    value = local.external-ip
  }
  key {
    path  = "infrastructure/storage-engine/external-port"
    value = local.external-storage-engine-port
  }
  key {
    path  = "infrastructure/storage-engine/external-endpoint"
    value = local.external-storage-engine-endpoint
  }
}