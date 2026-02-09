# Modalità Server
server = true

# Abilita bootstrap (utile se è il primo e unico server)
bootstrap_expect = 1

# Data dir persistente
data_dir = "/consul/data"

# Bind address
bind_addr = "0.0.0.0"

# Client address (da dove accetti connessioni API)
client_addr = "0.0.0.0"

# Porta HTTP dell'API
ports {
  http = 8500
}

ui_config {
  enabled = true
}

# Disabilita ACL
acl {
  enabled = false
}

# Nome del datacenter (facoltativo, ma utile)
datacenter = "hsh-dc"

# Log Level
log_level = "INFO"