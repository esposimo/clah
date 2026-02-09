# clah — Cloud at Home

CLI per gestire componenti di infrastruttura cloud in ambiente locale: Consul, ambienti, reti Docker e deploy di servizi (Terraform).

## Panoramica

**clah** è un tool a riga di comando che permette di:

- **Installare Consul** — sulla rete bridge di Docker, tramite script dedicato
- **Gestire ambienti** — creazione e gestione di ambienti (dev, prod, lab, …) con UUID persistenti
- **Definire le reti** — per ogni ambiente: una rete **provider** (infrastruttura) e una o più reti **applicative**
- **Service config** — lettura/scrittura chiave/valore tramite API Consul (KV)
- **Deploy** — prima le reti (Terraform), poi i servizi (es. Vault, ecc.)

I dati di registro (ambienti, reti) vivono in **Consul**; i moduli Terraform leggono da Consul come fonte di verità.

I comandi disponibili sono quelli definiti in `command.json` e sono **estendibili** aggiungendo definizioni nel path `extensions/` (es. `extensions/command_external.json`).

## Workflow consigliato

1. **Installazione Consul** — sulla rete bridge di Docker con `consul-service-config.sh` (vedi sotto).
2. **Creazione ambiente** — `clah env create <nome>` (es. `dev`).
3. **Creazione reti** — per quell’ambiente:
   - **una sola** rete di tipo **provider** (infrastruttura),
   - **una o più** reti di tipo **app** (applicative).
4. **Deploy delle reti** — Terraform per creare le reti Docker (es. `clah apply dev` sul progetto reti).
5. **Deploy dei servizi** — Terraform per ogni servizio (es. Vault, ecc.) sull’ambiente scelto.

## Requisiti

- **Bash**
- [jq](https://jqlang.github.io/jq/) — per il parsing JSON
- **curl** — per le chiamate al service config (Consul)
- **Docker** — per Consul e per le reti/servizi
- **Terraform** — per i comandi `apply`, `destroy`, `tf`
- **Consul** — in esecuzione (dopo l’installazione con lo script) per `config`, `env`, `networks` e backend Terraform

## Installazione / utilizzo

Non c’è installazione: si esegue lo script dalla root del repo.

```bash
# dalla root del progetto
./clah.sh --help
./clah.sh version
```

Per usarlo come comando globale puoi creare un alias o un symlink:

```bash
alias clah='/path/to/cliclah/clah.sh'
# oppure
ln -s /path/to/cliclah/clah.sh /usr/local/bin/clah
```

## Installazione di Consul

Consul va installato sulla **rete bridge di Docker** usando lo script dedicato:

```bash
# imposta l’endpoint se necessario (default: http://<DOCKER_HOST_IP>:16080)
export CLAH_SC_ENDPOINT="http://<host>:16080"   # opzionale

./consul-service-config.sh init
```

Lo script crea volume, immagine (da `service-config/Dockerfile`), avvia il container Consul in ascolto sulla porta 16080 (mappata sulla 8500 interna) e inizializza le chiavi KV (inclusi gli indici `environments/list-by-name` e `list-by-uuid`). Per rimuovere Consul e i dati:

```bash
./consul-service-config.sh destroy
```

Dopo l’`init`, puoi procedere con la creazione dell’ambiente e delle reti (vedi workflow sopra).

## Configurazione

- **Service config (Consul)**  
  L’endpoint di default è `http://<DOCKER_HOST_IP>:16080`. Puoi sovrascriverlo con:
  ```bash
  export CLAH_SC_ENDPOINT="http://host:8500"
  ```

- **Directory di configurazione**  
  clah usa la directory `.clah` nella root del progetto (creata al primo avvio) e il file `.clah/env` per variabili d’ambiente locali.

## Comandi

I comandi sono definiti in **`command.json`** e si possono estendere aggiungendo (o sovrascrivendo) definizioni nel path **`extensions/`** (es. `extensions/command_external.json`). I due file vengono uniti a runtime.

| Comando   | Descrizione |
|----------|-------------|
| `config` | Service config: ls, get, set, rm su chiavi Consul KV |
| `env`    | Ambienti: create, show, use, edit, rm |
| `networks` | Reti per ambiente: ls, get, create, rm (con -e/--env). Per ambiente: **una** rete provider, **più** reti app |
| `apply`  | Terraform apply su un ambiente (es. deploy reti o servizi) |
| `destroy` | Terraform destroy su un ambiente |
| `tf`     | Apply/destroy Terraform generico (con -d/--dir) |

Ogni comando supporta `help` / `-h` / `--help`; per i sottocomandi:  
`./clah.sh <comando> --help` e `./clah.sh <comando> <sottocomando> --help`.

### Esempi

```bash
# Help generale
./clah.sh help

# Ambienti
./clah.sh env create dev -d "Development"
./clah.sh env show -a
./clah.sh env use dev

# Reti (con ambiente): prima la rete provider, poi le reti applicative
./clah.sh networks -e dev create provider-net -s 10.0.1.0/24 -g 10.0.1.1 -t provider
./clah.sh networks -e dev create app-net -s 10.0.2.0/24 -g 10.0.2.1 -t app
./clah.sh networks -e dev ls

# Service config
./clah.sh config set path/to/key "value"
./clah.sh config ls path/
./clah.sh config get path/to/key

# Deploy reti (Terraform), poi servizi (es. Vault)
./clah.sh apply dev
./clah.sh apply dev -y
./clah.sh destroy dev -y
```

## Struttura del progetto

```
cliclah/
├── clah.sh                 # Entrypoint CLI
├── command.json            # Definizione comandi built-in
├── lib/
│   └── function-tools.sh   # Logica comune (help, parsing, Consul, env, …)
├── extensions/
│   └── command_external.json   # Comandi estesi (si uniscono a command.json)
├── bin/                    # Script dei comandi
│   ├── env.sh              # env create/show/use/edit/rm
│   ├── sc.sh               # config ls/get/set/rm
│   ├── networks.sh         # networks ls/get/create/rm
│   ├── apply.sh            # apply / destroy Terraform per ambiente
├── modules/                # Moduli Terraform riutilizzabili
│   ├── environment-resolver/       # Risoluzione nome ambiente → UUID (Consul)
│   └── environment-networks-registry/  # Reti per ambiente da Consul
├── services/               # Progetti Terraform per servizi
│   ├── networks/           # Reti (backend + variabili per env in cfg/)
│   └── vault/             # Vault (cfg per ambiente)
├── service-config/        # Configurazione Consul (Dockerfile, consul.hcl)
└── consul-service-config.sh   # Installazione Consul su rete bridge Docker (init / destroy)
```

## Estensioni

I comandi di base sono in **`command.json`**. Per estendere la CLI si aggiungono (o si sovrascrivono) definizioni nel path **`extensions/`** (es. `extensions/command_external.json`). I file vengono uniti a runtime: le estensioni possono aggiungere nuovi comandi o ridefinire quelli esistenti. Ogni comando punta a uno `source` (script in `bin/`) e a funzioni per main e subcommands.

## Service config e Consul

Il “service config” è l’API KV di Consul. Consul va installato sulla rete bridge di Docker con **`consul-service-config.sh init`** (vedi sezione *Installazione di Consul*); l’endpoint di default è sulla porta 16080. In `service-config/` trovi il Dockerfile e la configurazione Consul (`consul.hcl`).

I moduli Terraform in `modules/` leggono e/o scrivono Consul; il backend Terraform può usare Consul per lo state (configurato nei `backend.tfvars` sotto `services/*/cfg/<env>/`).

## Variabili d’ambiente rilevanti

| Variabile | Descrizione |
|-----------|-------------|
| `CLAH_SC_ENDPOINT` | URL del service config (Consul), es. `http://localhost:16080` |
| `CONSUL_HTTP_ADDR` | Usato da alcuni script (default `localhost:16080`) |
| `CONSUL_HTTP_SSL` | `true`/`false` per HTTPS verso Consul |

## Versione

Versione attuale: **0.1.0** (definita in `clah.sh`).  
Per visualizzarla: `./clah.sh version`.

---

Per domande o estensioni sui comandi, si può partire dalla struttura in `command.json` e dagli script in `bin/` e `lib/function-tools.sh`.
