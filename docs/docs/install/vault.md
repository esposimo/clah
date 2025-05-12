# Vault

## Initialize Vault Service

To initialize the Vault used by CLAH, simply run the script located at:

```bash title="bash"
clah init vault
```

This script performs the full initialization of the Vault service using the default configuration provided in the [variables.tfvars](https://github.com/esposimo/clah/blob/main/infrastructure/vault/config/variables.tfvars) file. No manual steps are required.

Once executed:

- A Consul container (used as the Vault's storage engine) will be started.
- The Vault container will be created and started, configured to communicate securely with Consul over an encrypted connection using self-signed certificates. A [`vault.hcl`](https://github.com/esposimo/clah/blob/main/infrastructure/vault/config/vault.hcl) file is used to build vault container
- The Vault will be automatically initialized.
- Both the **root key** and the **unseal key** will be stored inside the Service Config.
- The Vault instance will be available at:  
  `https://docker-host:28200`  
  *(replace `docker-host` with the IP or hostname of your Docker host machine)*

> ⚠️ **Important:** This Vault instance is meant to be **internal only** and **must not be exposed to the Internet**


## Vault Configuration Overview

The Vault service in CLAH is based on **HashiCorp Vault** with **Consul** configured as the storage engine. The Consul instance used for Vault's storage is separate from the one utilized for the Service Config.

Before running the initialization script, you can modify the default configuration by editing the `variables.tfvars` file found in `$CLAH_HOME/infrastructure/vault/config`


This file contains key variables that define the Vault and Consul setup. Here are the default values provided in the file:

### Consul Storage Engine Settings
```hcl title="storage engine variables"
storage-engine-image-name    = "hashicorp/consul"  
storage-engine-image-version = "1.20"  
storage-engine-volume        = "vol-storage-engine-vault"  
storage-engine-container     = "clah-storage-engine-vault"  
storage-engine-address-v4    = "10.190.10.2"  
storage-engine-ports         = [...] (list of ports and protocols)
```

### Vault Settings
```hcl title="vault service variables"
vault-image-name     = "hashicorp/vault"  
vault-image-version  = "1.19"  
vault-volume         = "vol-vault"  
vault-container-name = "clah-vault"  
vault-address-v4     = "10.190.10.3"  
vault-ports          = [  
    { container = 8200, host = 28200, protocol = "tcp" }  
]  
```
These settings control the container images, volumes, IP addresses, ports, and other key parameters of Vault and Consul.

!!! note 
    You can modify any of these values before proceeding with the Vault initialization to adapt the configuration to your environment.


## Service Config values

Once the script has completed, the following values will be available in the Service Config:

- `infrastructure/storage-engine/container-name`
- `infrastructure/storage-engine/build-image`
- `infrastructure/storage-engine/internal-ip`
- `infrastructure/storage-engine/internal-port`
- `infrastructure/storage-engine/internal-endpoint`
- `infrastructure/storage-engine/external-ip`
- `infrastructure/storage-engine/external-port`
- `infrastructure/storage-engine/external-endpoint`
- `infrastructure/vault/container-name`
- `infrastructure/vault/build-image`
- `infrastructure/vault/internal-ip`
- `infrastructure/vault/internal-port`
- `infrastructure/vault/internal-endpoint`
- `infrastructure/vault/external-ip`
- `infrastructure/vault/external-port`
- `infrastructure/vault/external-endpoint`
- `infrastructure/vault/root-key`
- `infrastructure/vault/unseal-key`

These paths represent the critical configuration values for both the Vault and Consul services, ensuring that they are properly set up in the Service Config for future access and use.

**Important:** Make sure that the Vault and Consul services are never exposed to the internet. They should always be secured within your internal infrastructure.


## Vault Configuration Details

After initialization, Vault is set up with the following configuration:

### Secrets Engine (Transit)

Vault uses a **Transit** secrets engine named `sops-kv`, which is configured to handle encryption and decryption operations. The key name used for infrastructure secrets is:

- `sops-key-infrastructure`

This key will be utilized by CLAH’s **SOPS** module to securely encrypt and decrypt secret files, ensuring that sensitive data is protected throughout your workflow.

### Vault Configuration File

The Vault container is initialized using the configuration file located at: `$CLAH_HOME/infrastructure/vault/config/vault.hcl`

This file contains the settings required for Vault to function properly within your infrastructure. You can customize the file before initialization if necessary, although the default settings should suffice for most users.

!!! note
    You can modify the `vault.hcl` file to further customize Vault’s behavior, such as adjusting storage backends, defining access policies, and more. Be cautious when modifying this file, as incorrect settings may prevent Vault from initializing properly.


