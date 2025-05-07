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
    name          = docker_network.infrastructure_network.id
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
  depends_on = [ docker_container.storage_engine_vault, data.external.docker_host_ip ]
  
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
    value = local.external_ip
  }
  key {
    path  = "infrastructure/storage-engine/external-port"
    value = local.external_storage_engine_port
  }
  key {
    path  = "infrastructure/storage-engine/external-endpoint"
    value = local.external_storage_engine_endpoint
  }
}


# vault

resource "tls_private_key" "vault_certificate_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_self_signed_cert" "vault_certificate" {
  private_key_pem = tls_private_key.vault_certificate_key.private_key_pem

  subject {
    common_name         = local.certs.common_name
    country             = local.certs.country
    province            = local.certs.province
    locality            = local.certs.locality
    organization        = local.certs.organization
  }

  dns_names             = local.certs.dns_names
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "docker_image" "build_vault" {
  name         = "${var.vault-image-name}:${var.vault-image-version}"
  force_remove = false
  keep_locally = false
}

resource "docker_volume" "volume_vault" {
    name   = "${var.vault-volume}"
    driver = "local"
}

resource "docker_container" "vault_container" {
  depends_on    = [ docker_image.build_vault , docker_volume.volume_vault ]
  rm            = false

  name          = "${var.vault-container-name}"
  image         = docker_image.build_vault.image_id

  networks_advanced {
    name          = docker_network.infrastructure_network.id
    ipv4_address  = var.vault-address-v4
  }

  command = ["server"]
  
  capabilities {
    add = ["CAP_IPC_LOCK"]
  }

  lifecycle {
    ignore_changes = [ 
      log_opts, log_driver
     ]
  }

  volumes {
      container_path = "/consul/data"
      volume_name    = docker_volume.volume_vault.name
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
    for_each = var.vault-ports
    content {
        internal = ports.value.container
        external = ports.value.host
        protocol = ports.value.protocol
    }
  }

  upload {
    file          = local.certs.cert_file
    content       = tls_self_signed_cert.vault_certificate.cert_pem
    permissions   = "0644"
  }

  upload {
    file          = local.certs.key_file
    content       = tls_private_key.vault_certificate_key.private_key_pem
    permissions   = "0644"
  }

  upload {
    content    = templatefile("./config/vault.hcl", {
      cert_file               = local.certs.cert_file ,
      key_file                = local.certs.key_file ,
      storage_engine_endpoint = local.external_storage_engine_endpoint
    })
    file = "/vault/config/vault.hcl"
  }

  upload {
    source      = "./config/init-vault.sh"
    file        = "/tmp/init-vault.sh"
    executable  = true
    permissions = "0755"
  }
}


resource "consul_keys" "vault_service_config" {
  depends_on = [ docker_container.vault_container, data.external.docker_host_ip ]
  
  key {
    path  = "infrastructure/vault/container-name"
    value = var.vault-container-name
  }
  key {
    path  = "infrastructure/vault/build-image"
    value = "${var.vault-image-name}:${var.vault-image-version}"
  }
  key {
    path  = "infrastructure/vault/internal-ip"
    value = var.vault-address-v4
  }
  key {
    path  = "infrastructure/vault/internal-port"
    value = "8200"
  }
  key {
    path  = "infrastructure/vault/internal-endpoint"
    value = "https://${var.vault-address-v4}:8200/"
  }
  key {
    path  = "infrastructure/vault/external-ip"
    value = local.external_ip
  }
  key {
    path  = "infrastructure/vault/external-port"
    value = local.external_vault_port
  }
  key {
    path  = "infrastructure/vault/external-endpoint"
    value = local.external_vault_endpoint
  }
}


resource "vaultoperator_init" "vault_bootstrap" {
  depends_on = [ docker_container.vault_container ]
  secret_shares      = 1
  secret_threshold   = 1
}

resource "consul_keys" "config_vault_secret" {
  depends_on = [ vaultoperator_init.vault_bootstrap ]
  
  key {
    path  = "infrastructure/vault/root-key"
    value = vaultoperator_init.vault_bootstrap.root_token
  }

  key {
    path  = "infrastructure/vault/unseal-key"
    value = vaultoperator_init.vault_bootstrap.keys[0]
  }
}

data "http" "unseal_vault" {
  depends_on = [ vaultoperator_init.vault_bootstrap ]
  url = "${local.external_vault_endpoint}/v1/sys/unseal"
  insecure = true
  method = "POST"
  request_body = format("{\"key\":\"%s\"}", vaultoperator_init.vault_bootstrap.keys[0])
}