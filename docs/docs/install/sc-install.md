# Service Config

The first essential component to deploy in the CLAH infrastructure is the **Consul container**. This instance of Consul acts as a **Service Config Registry**, storing key infrastructure metadata that will be used by other services and deployment scripts.

## Purpose

The Consul container provides a central registry to:

- Store information about service endpoints (e.g., Vault, API Gateway).
- Act as a simple key-value store accessible via HTTP API.
- Share infrastructure metadata with deployment scripts for your applications.

> **Important**: This container is not intended for production usage as-is.  
> It runs with **ACLs disabled**, **unencrypted traffic**, and **no authentication mechanisms**.  
> **Never expose this service to the internet.** It must remain inside a trusted, internal network (LAN).

## How to launch it

Run the following command:

```bash title="bash"
$ clah init sc
```

This command will:

- Build and start a Consul Docker container.
- Expose it on port `CLAH_SC_HOST_PORT` of the host machine.
- Create a Docker volume for persistent data storage.
- Skip any security configuration to keep the setup simple for development.

Once started, you can access the HTTP web console at:

```bash title="bash"
$ http://<docker-host>:<CLAH_SC_HOST_PORT>
```

and HTTP API at:
```bash title="bash"
$ http://<docker-host>:<CLAH_SC_HOST_PORT>/v1/kv
```

## Configuration Variables

The script supports several environment variables to customize the container configuration. If not set, default values will be used:

| Variable                  | Description                               | Default Value                  |
|---------------------------|-------------------------------------------|--------------------------------|
| `CLAH_SC_BASE_IMAGE`      | Docker image to use for Consul            | `hashicorp/consul:1.20`        |
| `CLAH_SC_CONTAINER_NAME`  | Name of the container                     | `service-config-container`     |
| `CLAH_SC_CONTAINER_IMAGE` | Name of the image to build                | `service-config-image`         |
| `CLAH_SC_VOLUME_NAME`     | Docker volume name for Consul data        | `service-config-volume`        |
| `CLAH_SC_HOST_PORT`       | Host port to access Consul                | `15080`                        |

You can override these by exporting them in your shell before launching the script:

```bash title="bash"
export CLAH_SC_HOST_PORT=15100
export CLAH_SC_CONTAINER_NAME=my-consul
clah init sc
```

!!! warning
    If you want to use a different port for the service config, it's recommended to set the `CLAH_SC_HOST_PORT` variable in your `.bashrc`. Exporting it only in the current Bash session may lead to issues when opening new SSH sessions.

## Security Considerations

The Consul instance started by `clah sc init` is intentionally configured without ACLs and uses unencrypted communication. This setup is **only intended for local or LAN-restricted environments**.

**Never expose this Consul service directly to the internet.**

This Consul instance is designed to act as a lightweight **Service Config Registry**, storing useful infrastructure metadata such as:

- Endpoints of core services (Vault, API Gateway, etc.)
- Runtime configuration for deploy scripts

## Next Step: Initialize Network

With the Service Config (Consul) now running, the next step is to initialize **Infrastructure Network**.
➡️ Follow the guide at [Infrastructure Network](network.md)

