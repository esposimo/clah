# Infrastructure Network

The first Terraform-based step in the CLAH initialization process is the creation of the **infrastructure network**. This network will exclusively host core CLAH services such as the API Gateway, Authentication Service, Key Vault, and others.

## Create the Infrastructure Network

To create the network, run the following script:

```bash title="bash"
$ clah init network
```
This script will use predefined configuration values from the file [variables.tfvars](https://github.com/esposimo/clah/blob/main/infrastructure/network/config/variables.tfvars) in `$CLAH_HOME/infrastructure/network/config`

The default values are:

```hcl title="$CLAH_HOME/infrastructure/network/config/variables.tfvars"
network-infra-name    = "clah-infrastructure-network"
network-infra-gateway = "10.190.10.1"
network-infra-subnet  = "10.190.10.1/24"
```

Once the script is executed, a new infrastructure network will be created using these values.

## Customize Network Configuration

The `variables.tfvars` file defines the core parameters for the infrastructure network. You can modify these values before running the `apply.sh` script if you want to change the network configuration.

Here’s a breakdown of the variables:

- `network-infra-name`:  
  The name of the Docker network that will be created for CLAH infrastructure services.

- `network-infra-gateway`:  
  The gateway IP address for the network. This is typically the first IP in the subnet.

- `network-infra-subnet`:  
  The CIDR block representing the full address range of the infrastructure network.

To apply your own custom network configuration, simply edit the file `$CLAH_HOME/infrastructure/network/config/variables.tfvars` before running the apply script.

## Values Stored in Service Config

Once the network is created, the following values will be automatically stored in the Service Config (Consul) under these paths:

- `infrastructure/network/name`  
- `infrastructure/network/subnet`  
- `infrastructure/network/gateway`  
- `infrastructure/network/docker-host-ip`  

These paths are essential for other services to retrieve the infrastructure network configuration.

!!! info
    The value of `docker-host-ip` is determined by the script `$CLAH_HOME/infrastructure/network/get_docker_ip.sh`.  
    You may edit this script if you want to manually define the IP address of the Docker host instead of detecting it automatically.


## Proceed to Vault Setup

With the infrastructure network successfully created and registered in the Service Config, you're now ready to move on to the next critical step: setting up the **Vault** service.

Follow the [Vault documentation page](vault.md) to initialize and configure it as the secure key and secret store for all CLAH services.


