# Environment Networks Registry (Consul)

## Description

This module retrieves **all network information associated with an environment** from Consul and exposes it in multiple structured forms.

It acts as a **read-only registry aggregator**, resolving:
- provider network
- application networks
- network UUIDs and names
- full network metadata (subnet, gateway, type, description, creation time)

The module is designed to be consumed by other Terraform modules that need:
- network UUIDs
- network names
- bidirectional name ↔ UUID mappings
- detailed network attributes

No resources are created or modified.

---

## How it works

1. Resolves the environment UUID starting from its logical name
2. Reads network indexes from Consul:
   - provider network UUID
   - application networks UUIDs
3. Fetches detailed information for each network
4. Exposes multiple normalized views of the same data

Consul is treated as the **authoritative source of truth**.

---

## Usage

```hcl
module "networks" {
  source = "../../modules/environment-networks"

  env = "home"
}
```
```hcl
locals {
  provider_network_id = module.networks.list_uuid.provider
  app_networks_ids    = module.networks.list_uuid.apps
}
```

## Input variables
| Name  | Type     | Description                                                     | Required |
| ----- | -------- | --------------------------------------------------------------- | -------- |
| `env` | `string` | Logical name of the environment whose networks must be resolved | yes      |

## Outputs
 `networks-list`

Complete aggregated object containing all resolved information.

This output is intended for advanced consumers or debugging purposes.

`list-uuid`

Contains only network UUIDs.

Structure:

- `provider`: provider network UUID
- `apps`: list of application network UUIDs

Use this output when only identifiers are required.


`list-names`

Contains only network names.

Structure:

- `provider`: provider network name
- `apps`: list of application network names

Useful for display, logging, or UI layers.

`list-by-name`

Bidirectional lookup by network name.

Structure:

- `provider`: map(name → uuid)
- `apps`: map(name → uuid)

Ideal when resolving UUIDs starting from human-readable names.

`list-by-uuid`

Bidirectional lookup by network UUID.

Structure:

- `provider`: map(uuid → name)
- `apps`: map(uuid → name)

Useful when consuming UUIDs coming from other modules or external systems.

`details`

Full metadata for all networks, indexed by UUID.

Each entry contains:

- `name`
- `subnet`
- `gateway`
- `type` (provider / app)
- `description`
- `created`

This output is the closest representation of the raw registry data.

## Providers

This module requires the following provider to be configured by the caller:

- `hashicorp/consul` (>= 2.22.1)

The module does not configure the provider itself.

## Design notes
- This module is intentionally side-effect free
- It aggregates multiple Consul keys into a normalized API
- All outputs derive from a single internal data model
- Multiple output views avoid duplication of lookup logic in consumers

## Limitations
- Assumes a consistent and valid Consul registry layout
- Missing keys or malformed JSON will cause Terraform plan errors
- No validation is performed on network semantics (CIDR overlap, etc.)

