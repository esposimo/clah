# Step 1 – Launch the Consul Container (Service Config)

The first essential component to deploy in the CLAH infrastructure is the **Consul container**. This instance of Consul acts as a **Service Config Registry**, storing key infrastructure metadata that will be used by other services and deployment scripts.

## 🧩 Purpose

The Consul container provides a central registry to:

- Store information about service endpoints (e.g., Vault, API Gateway).
- Act as a simple key-value store accessible via HTTP API.
- Share infrastructure metadata with deployment scripts for your applications.

> ⚠️ **Important**: This container is not intended for production usage as-is.  
> It runs with **ACLs disabled**, **unencrypted traffic**, and **no authentication mechanisms**.  
> **Never expose this service to the internet.** It must remain inside a trusted, internal network (LAN).

## ▶️ How to launch it

From your project root (`$CLAH_HOME`), run the following script:

```bash title="bash"
$ ./bin/consul-tf-state.sh
```

This script will:

- Build and start a Consul Docker container.
- Expose it on port 15080 of the host machine.
- Create a Docker volume for persistent data storage.
- Skip any security configuration to keep the setup simple for development.

Once started, you can access the HTTP web console at:

```bash title="bash"
$ http://<your-host>:15080
```

and HTTP API at:
```bash title="bash"
$ http://<your-host>:15080/v1/kv
```

## ⚙️ Configuration Variables

The script supports several environment variables to customize the container configuration. If not set, default values will be used:

| Variable             | Description                               | Default Value                  |
|----------------------|-------------------------------------------|--------------------------------|
| `SC_BASE_IMAGE`      | Docker image to use for Consul            | `hashicorp/consul:1.20`        |
| `SC_CONTAINER_NAME`  | Name of the container                     | `service-config-container`     |
| `SC_CONTAINER_IMAGE` | Name of the image to build                | `service-config-image`         |
| `SC_VOLUME_NAME`     | Docker volume name for Consul data        | `service-config-volume`        |
| `SC_HOST_PORT`       | Host port to access Consul                | `15080`                        |

You can override these by exporting them in your shell before launching the script:

```bash title="bash"
export SC_HOST_PORT=15100
export SC_CONTAINER_NAME=my-consul
./bin/consul-tf-state.sh
```

## 🔒 Security Considerations

The Consul instance started by `consul-tf-state.sh` is intentionally configured without ACLs and uses unencrypted communication. This setup is **only intended for local or LAN-restricted environments** during development or home lab usage.

**⚠️ Never expose this Consul service directly to the internet.**

It is strongly recommended to:

- Deploy the service on an isolated network segment.
- Use firewall rules to limit access to trusted machines only.
- Enable ACLs and TLS if you plan to use this in a production-like or semi-public environment (refer to the [official Consul security documentation](https://developer.hashicorp.com/consul/docs/security) for details).

This Consul instance is designed to act as a lightweight **Service Config Registry**, storing useful infrastructure metadata such as:

- Endpoints of core services (Vault, API Gateway, etc.)
- Runtime configuration for deploy scripts

## ⏭️ Next Step: Initialize Vault

With the Service Config (Consul) now running, the next step is to initialize **Vault**, the core component for managing secrets and cryptographic keys in your CLAH environment.

Vault will be configured to use the Consul instance as its storage backend, enabling persistent and consistent secret management across your infrastructure.

➡️ Follow the guide at [Vault Initialization](../vault/init.md) to:

- Start the Vault container
- Initialize the key store
- Unseal the Vault
- Store essential infrastructure secrets

