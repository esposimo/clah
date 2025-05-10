resource "docker_image" "build_elastic_master" {
  name         = "${var.elastic-image-name}:${var.elastic-image-version}"
  force_remove = false
  keep_locally = false
}

resource "docker_image" "build_elastic_cold" {
  name         = "${var.elastic-image-name}:${var.elastic-image-version}"
  force_remove = false
  keep_locally = false
}

resource "docker_volume" "volume_elastic_master" {
    name   = "${var.elastic-master-data-volume}"
    driver = "local"
}

resource "docker_volume" "volume_elastic_cold" {
    name   = "${var.elastic-cold-data-volume}"
    driver = "local"
}

resource "docker_container" "elastic_master" {
  depends_on    = [ docker_image.build_elastic_master , docker_volume.volume_elastic_master ]
  rm            = false

  name          = "${var.elastic-master-container-name}"
  image         = docker_image.build_elastic_master.image_id

  networks_advanced {
    name          = docker_network.infrastructure_network.id
    ipv4_address  = var.elastic-master-address-v4
  }

  lifecycle {
    ignore_changes = [ 
      log_opts, log_driver
     ]
  }

  cpus = "1.0" 
  memory = 1024

  ulimit {
    hard = -1
    name = "memlock"
    soft = -1
  }

  dynamic "ports" {
    for_each = var.elastic-master-ports
    content {
        internal = ports.value.container
        external = ports.value.host
        protocol = ports.value.protocol
    }
  }

  volumes {
      container_path = "/usr/share/elasticsearch/data"
      volume_name    = docker_volume.volume_elastic_master.name
  }
  volumes {
      container_path = "/etc/timezone"
      volume_name    = "/etc/timezone"
  }
  volumes {
      container_path = "/etc/localtime"
      volume_name    = "/etc/localtime"
  }

  env = setunion(var.elastic-master-env-variable, ["ELASTIC_PASSWORD=${data.external.random_password.result["random_password"]}"])

}

resource "docker_container" "elastic_cold" {
  depends_on    = [ docker_image.build_elastic_cold , docker_volume.volume_elastic_cold , docker_container.elastic_master ]
  rm            = false

  name          = "${var.elastic-cold-container-name}"
  image         = docker_image.build_elastic_cold.image_id

  networks_advanced {
    name          = docker_network.infrastructure_network.id
    ipv4_address  = var.elastic-cold-address-v4
  }

  lifecycle {
    ignore_changes = [ 
      log_opts, log_driver
     ]
  }

  cpus = "1.0" 
  memory = 1024

  ulimit {
    hard = -1
    name = "memlock"
    soft = -1
  }

  volumes {
      container_path = "/usr/share/elasticsearch/data"
      volume_name    = docker_volume.volume_elastic_cold.name
  }
  volumes {
      container_path = "/etc/timezone"
      volume_name    = "/etc/timezone"
  }
  volumes {
      container_path = "/etc/localtime"
      volume_name    = "/etc/localtime"
  }

  env = var.elastic-cold-env-variable

}


resource "consul_keys" "elastic_master_config" {
  depends_on = [ docker_container.elastic_master ]
  
  key {
    path  = "infrastructure/elastic/build-image"
    value = "${var.elastic-image-name}:${var.elastic-image-version}"
  }
  key {
    path  = "infrastructure/elastic/master/container-name"
    value = var.elastic-master-container-name
  }
  key {
    path  = "infrastructure/elastic/master/internal-ip"
    value = var.elastic-master-address-v4
  }
  key {
    path  = "infrastructure/elastic/master/internal-port"
    value = "9200"
  }
  key {
    path  = "infrastructure/elastic/master/internal-endpoint"
    value = "https://${var.vault-address-v4}:9200/"
  }
  key {
    path  = "infrastructure/elastic/master/external-ip"
    value = local.external-ip
  }
  key {
    path  = "infrastructure/elastic/master/external-port"
    value = local.external-ip
  }  
  key {
    path  = "infrastructure/elastic/master/external-endpoint"
    value = local.external-elastic-master-endpoint
  }
  key {
    path  = "infrastructure/elastic/master/username"
    value = "elastic"
  }
  key {
    path  = "infrastructure/elastic/master/password"
    value = data.external.random_password.result["random_password"]
  }
}

resource "consul_keys" "elastic_cold_config" {
  depends_on = [ docker_container.elastic_cold ]
  
  key {
    path  = "infrastructure/elastic/cold/container-name"
    value = var.elastic-cold-container-name
  }
  key {
    path  = "infrastructure/elastic/cold/internal-ip"
    value = var.elastic-cold-address-v4
  }
  key {
    path  = "infrastructure/elastic/cold/internal-port"
    value = "9200"
  }
  key {
    path  = "infrastructure/elastic/cold/internal-endpoint"
    value = "https://${var.elastic-cold-address-v4}:9200/"
  }
  key {
    path  = "infrastructure/elastic/cold/external-ip"
    value = local.external-ip
  }
  key {
    path  = "infrastructure/elastic/cold/username"
    value = "elastic"
  }
  key {
    path  = "infrastructure/elastic/cold/password"
    value = data.external.random_password.result["random_password"]
  }
}
