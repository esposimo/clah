network-infra-name      = "clah-infrastructure-network"
network-infra-gateway   = "10.190.10.1"
network-infra-subnet    = "10.190.10.1/24"

storage-engine-image-name       = "hashicorp/consul"
storage-engine-image-version    = "1.20"
storage-engine-volume           = "vol-storage-engine-vault"
storage-engine-container        = "clah-storage-engine-vault"
storage-engine-address-v4       = "10.190.10.2"
storage-engine-ports = [
    { container = 8300, host = 15300, protocol = "tcp" },
    { container = 8301, host = 15301, protocol = "tcp" },
    { container = 8301, host = 15301, protocol = "udp" },
    { container = 8302, host = 15302, protocol = "tcp" },
    { container = 8302, host = 15302, protocol = "udp" },
    { container = 8500, host = 15500, protocol = "tcp" },
    { container = 8600, host = 15600, protocol = "tcp" },
    { container = 8600, host = 15600, protocol = "udp" }
]


vault-image-name        = "hashicorp/vault"
vault-image-version     = "1.19"
vault-volume            = "vol-vault"
vault-container-name    = "clah-vault"
vault-address-v4        = "10.190.10.3"
vault-ports = [
    { container = 8200, host = 28200, protocol = "tcp" }
]

elastic-image-name            = "docker.elastic.co/elasticsearch/elasticsearch"
elastic-image-version         = "8.10.2"
elastic-master-address-v4     = "10.190.10.4"
elastic-master-container-name = "clah-elastic-master"
elastic-master-data-volume    = "elastic-master-data"
elastic-master-env-variable   = [
    "node.name=elastic_content",
    "node.roles=master, data_content, data_hot",
    "cluster.name=cluster_elastic",
    "discovery.seed_hosts=clah-elastic-master,clah-elastic-cold",
    "cluster.initial_master_nodes=elastic_content",
    "bootstrap.memory_lock=true",
    "xpack.security.enabled=false",
    "network.host=0.0.0.0",
    "ES_JAVA_OPTS=-Xms512m -Xmx512m"
]
elastic-master-ports = [
    { container = 9200, host = 29200, protocol = "tcp" }
]

elastic-cold-address-v4     = "10.190.10.5"
elastic-cold-container-name = "clah-elastic-cold"
elastic-cold-data-volume    = "elastic-cold-data"
elastic-cold-env-variable   = [
    "node.name=elastic_warm",
    "node.roles=data_warm, data_cold",
    "cluster.name=cluster_elastic",
    "discovery.seed_hosts=clah-elastic-master,clah-elastic-cold",
    "cluster.initial_master_nodes=elastic_content",
    "bootstrap.memory_lock=true",
    "xpack.security.enabled=false",
    "network.host=0.0.0.0",
    "ES_JAVA_OPTS=-Xms512m -Xmx512m"
]

#${CLAH_ELASTIC_MASTER_DATA_PATH}:/usr/share/elasticsearch/data \
#elastic-master-address-v4
#elastic-master-image-name
#elastic-master-image-version
#elastic-master-container-name
#elastic-maseter-bind-mount
#elastic-master-env-variable