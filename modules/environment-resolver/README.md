# Environment UUID lookup (Consul)

## Description

This module resolves an environment UUID starting from its logical name, using Consul as a centralized source of truth.

It is designed to be a read-only lookup module, meant to decouple environment identification (UUIDs) from hardcoded values inside Terraform configurations.

Typical use cases:
- Mapping human-friendly environment names (home, prod, lab) to immutable UUIDs
- Enforcing consistent environment identity across modules
- Avoiding UUID duplication in Terraform code

---

## How it works

The module:
1. Reads a JSON document from Consul at the key:
   environments/list-by-name
2. Decodes the JSON map
3. Extracts the UUID associated with the requested environment name

Expected Consul value format:
```json
{
  "home": {
    "uuid": "b1f8a3c4-...."
  },
  "prod": {
    "uuid": "9e23a1ff-...."
  }
}
```
---

## Usage
```hcl
module "env_lookup" {
  source = "../modules/env-lookup"
  env    = "home"
}
```
Example usage in another module:
```hcl
locals {
  environment_id = module.env_lookup.env_uuid
}
```
---

## Inputs

| Name  | Type     | Description                                | Required |
| ----- | -------- | ------------------------------------------ | -------- |
| `env` | `string` | Logical name of the environment to resolve | yes      |

---

## Outputs

| Name       | Description                                    |
| ---------- | ---------------------------------------------- |
| `env_uuid` | UUID associated with the requested environment |

---

## Providers

This module requires the following provider to be configured by the caller:

- `hashicorp/consul` (>= 2.22.1)

The module does not configure the provider itself and assumes Consul is reachable.

---

## Design notes

- This module is intentionally side-effect free
- No resources are created or modified
- Consul is treated as a configuration registry, not as Terraform state

---

## Limitations

- The module assumes the environment name exists in Consul
- Missing or malformed keys will result in a Terraform error at plan time
