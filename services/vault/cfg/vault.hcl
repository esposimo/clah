ui = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"  
  tls_cert_file = "${cert_file}"
  tls_key_file  = "${key_file}"
}

storage "consul" {
  address = "${storage_engine_endpoint}"
  path    = "vault/"
}

disable_mlock = true
