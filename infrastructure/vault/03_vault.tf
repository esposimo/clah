resource "tls_private_key" "vault_certificate_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_self_signed_cert" "vault_certificate" {
  private_key_pem = tls_private_key.vault_certificate_key.private_key_pem

  subject {
    common_name         = local.certs.vault.common-name
    country             = local.certs.vault.country
    province            = local.certs.vault.province
    locality            = local.certs.vault.locality
    organization        = local.certs.vault.organization
  }

  dns_names             = local.certs.vault.dns-names
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
  depends_on    = [ docker_image.build_vault , docker_volume.volume_vault , docker_container.storage_engine_vault ]
  rm            = false

  name          = "${var.vault-container-name}"
  image         = docker_image.build_vault.image_id

  networks_advanced {
    name          = data.consul_keys.infrastructure_network.var.infra-net
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
    file          = local.certs.vault.cert-file
    content       = tls_self_signed_cert.vault_certificate.cert_pem
    permissions   = "0644"
  }

  upload {
    file          = local.certs.vault.key-file
    content       = tls_private_key.vault_certificate_key.private_key_pem
    permissions   = "0644"
  }

  upload {
    content    = templatefile("./config/vault.hcl", {
      cert_file               = local.certs.vault.cert-file ,
      key_file                = local.certs.vault.key-file ,
      storage_engine_endpoint = local.external-storage-engine-endpoint
    })
    file = "/vault/config/vault.hcl"
  }
}

resource "consul_keys" "vault_service_config" {
  depends_on = [ docker_container.vault_container, data.consul_keys.docker-host-ip ]
  
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
    value = local.external-ip
  }
  key {
    path  = "infrastructure/vault/external-port"
    value = local.external-vault-port
  }
  key {
    path  = "infrastructure/vault/external-endpoint"
    value = local.external-vault-endpoint
  }
}