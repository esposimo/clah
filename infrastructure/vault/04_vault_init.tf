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
  url = "${local.external-vault-endpoint}/v1/sys/unseal"
  insecure = true
  method = "POST"
  request_body = format("{\"key\":\"%s\"}", vaultoperator_init.vault_bootstrap.keys[0])
}

resource "vault_mount" "sops" {
  depends_on = [ data.http.unseal_vault ]
  path                      = "sops-kv"
  type                      = "transit"
  description               = "Chiavi di crittografia per sops"
}

resource "vault_transit_secret_backend_key" "key" {
  depends_on = [ vault_mount.sops ]
  backend = vault_mount.sops.path
  name    = "sops-key-infrastructure"
  deletion_allowed = true
}