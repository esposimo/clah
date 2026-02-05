resource "tls_private_key" "vault_certificate_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}
resource "tls_self_signed_cert" "vault_certificate" {
  private_key_pem = tls_private_key.vault_certificate_key.private_key_pem

  subject {
    common_name         = var.vault-cert.common-name
    country             = var.vault-cert.country
    province            = var.vault-cert.province
    locality            = var.vault-cert.locality
    organization        = var.vault-cert.organization
  }

  dns_names             = var.vault-cert.dns-names
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
  keep_locally = var.destroy-volumes-on-delete
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
    name        = data.consul_keys.network_provider.var.name
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
    file          = "/vault/certs/vault.crt"
    content       = tls_self_signed_cert.vault_certificate.cert_pem
    permissions   = "0644"
  }

  upload {
    file          = "/vault/certs/vault.key"
    content       = tls_private_key.vault_certificate_key.private_key_pem
    permissions   = "0644"
  }

  upload {
    content    = templatefile("./cfg/vault.hcl", {
      cert_file               = "/vault/certs/vault.crt" ,
      key_file                = "/vault/certs/vault.key" ,
      storage_engine_endpoint = local.storage_engine_endpoint_container
    })
    file = "/vault/config/vault.hcl"
  }

  publish_all_ports = var.publish-vault-ports
  restart = "always"

}



resource "consul_keys" "vault_service_config" {
  depends_on = [ docker_container.vault_container ]
  
  key {
    path    = "infrastructure/vault/service/ipv4-address"
    value   = local.vault_ipv4_address
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/service/gui-container-port"
    value   = "8200"
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/service/gui-host-port"
    value   = local.vault_gui_host_port
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/service/endpoint-container"
    value   = local.vault_endpoint_container
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/service/endpoint-host"
    value   = local.vault_endpoint_host
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/container/vault-image-name"
    value   = var.vault-image-name
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/container/vault-image-version"
    value   = var.vault-image-version
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/container/volume-name"
    value   = var.vault-volume
    delete  = true 
  }
  key {
    path    = "infrastructure/vault/container/container-name"
    value   = var.vault-container-name
    delete  = true 
  }
  # ports, volumes
}
