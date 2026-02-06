# run-application

Modulo Terraform per il deploy di uno o più container Docker, con registrazione metadati su Consul.

## Nome modulo
Il nome richiesto `run-application` è coerente e chiaro. In alternativa, solo se vuoi enfatizzare la natura di stack, puoi usare `run-application-stack`.

## Provider usati
- `cybershard/docker` `1.0.0`
- `hashicorp/consul` `2.23.0`
- `hashicorp/random` (per UUID persistenti in state)

## Moduli interni usati
- `environment-resolver` (risolve `env_uuid`)
- `environment-networks-registry` (risolve reti provider/app e mapping nome/uuid)

## Input
| Variabile | Tipo | Descrizione |
|---|---|---|
| `env` | `string` | Nome logico ambiente |
| `application_network_name` | `string` | Rete applicativa obbligatoria su cui collegare tutti i container |
| `attach_infrastructure_network` | `bool` | Se `true`, collega tutti i container anche alla rete provider |
| `containers_spec_file` | `string` | Path file JSON con la definizione dei container |

## Struttura JSON supportata
```json
[
  {
    "name": "my-container",
    "image": "nginx:1.27",
    "build": {
      "context": "./docker/nginx",
      "file": "Dockerfile"
    },
    "networks": ["app-a", "app-b"],
    "attach_on_provider": false,
    "ports": [
      {"host": "8080", "container": "80", "protocol": "tcp"}
    ],
    "mounts": [
      {"/etc/localtime": "/etc/localtime"}
    ],
    "volumes": [
      {"name": "nginx-data", "path": "/var/lib/nginx", "destroy_on_recreate": false}
    ],
    "devices": [
      {"name": "/dev/ttyUSB0", "path": "/dev/ttyUSB0"}
    ],
    "var": {
      "environment": {
        "A": "B"
      }
    }
  }
]
```

> Nota: la parte `var.secrets` è volutamente ignorata in questa versione.

## Comportamento
- Se `build` è presente, viene creata una `docker_image` da context/dockerfile e usata al posto di `image`.
- Le reti indicate in `networks` devono esistere nell'ambiente; in caso contrario il piano fallisce.
- Ogni container viene sempre collegato a `application_network_name`.
- `attach_infrastructure_network` forza l'attach alla rete provider per tutti.
- `attach_on_provider` abilita l'attach provider per il singolo container.
- Viene generato un UUID stack (`random_uuid.application`) e un UUID per container (`random_uuid.container`).
- I metadati vengono scritti in Consul con il path:
  - `applications/<env-uuid>/<app-uuid>/<container-uuid>/...`

## Output principali
- `env_uuid`
- `application_uuid`
- `container_uuids`
- `provider_network_uuid`
- `app_network_uuids`
- `container_ips_by_network_uuid`

## Esempio uso
```hcl
module "run_application" {
  source = "../../modules/run-application"

  env                           = "home"
  application_network_name      = "app-core"
  attach_infrastructure_network = false
  containers_spec_file          = "${path.module}/containers.json"
}
```

## JSON file vs variabili Terraform
Per questo scenario è corretto usare un file JSON esterno:
- facilita gestione di stack multi-container complessi
- più semplice da versionare separatamente
- evita input Terraform troppo annidati e verbosi

Se in futuro vuoi validazioni più forti a plan-time, possiamo aggiungere anche una variabile tipizzata alternativa (`list(object(...))`) mantenendo il JSON come opzione.
