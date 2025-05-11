# Clah – Cloud at Home

Welcome to the official documentation of **Clah** (Cloud at Home), a project designed to create and manage a personal, reliable, and secure **local cloud**, entirely based on open-source technologies.

## 🎯 Purpose

**Clah** provides a **minimal but solid infrastructure layer** to run your own applications and services, replicating the essential features of major cloud providers (AWS, Azure, GCP) but in a self-hosted, local environment.

Everything runs with **Docker** and can be deployed on a single node (NUC, mini PC, or home server).

## 🧱 Core Components

Clah is a modular, containerized infrastructure offering:

- 🧑‍💻 **Centralized authentication** with [Autentik](https://goauthentik.io/)+[OpenLDAP](https://hub.docker.com/r/bitnami/openldap/), supporting SSO, SAML, OAuth2, and MFA (like Microsoft Entra ID)
- 🧾 **Central service configuration** for managing app settings with [Hashicorp Consul](https://developer.hashicorp.com/consul)
- 💾 **Local object storage** with [MinIO], S3-compatible (like Amazon S3 or Azure Blob)
- 🗝️ **Local key vault** using [HashiCorp Vault](https://developer.hashicorp.com/vault), for secure storage of secrets and encryption keys (like Azure Key Vault) managed with [SOPS](https://github.com/getsops)
- 📡 **Event broker** (Kafka, MQTT, etc.) for asynchronous service communication
- 📊 **Monitoring dashboards** and centralized logs with [Grafana] + [Elastic Stack] (like Azure Monitor or CloudWatch)
- 🔁 **Automated backups** with [Duplicati]
- 🌍 **Multiple public endpoints** managed with [Nginx Proxy Manager], including automatic Let's Encrypt certificate generation for exposing services to the internet
- 🔔 **Integrated notification system**, based on [ntfy](https://ntfy.sh/)
- 🚀 **Easy application deployment** using Docker containers

## ⚙️ Infrastructure as Code (IaC)

The entire infrastructure is managed using **Terraform**](https://developer.hashicorp.com/terraform), following an **Infrastructure as Code** (IaC) approach that allows:

- Declarative definition of your entire stack
- Full version control of infrastructure changes
- Automated environment provisioning, updates, and teardown

Provisioning, configuration, and daily management are handled via the `clah` **command-line tool**, which orchestrates all services and infrastructure layers.

> A future release will include an **HTTP API layer** as an alternative to the CLI tool, enabling programmatic control and integration with graphical interfaces or external systems.

## 🌐 Compare to public cloud services

| Clah Service            | Public Cloud Equivalent | Functionality                                  |
|-------------------------|--------------------------|------------------------------------------------|
| Authentik + OpenLDAP    | Azure Entra / AWS IAM    | Identity management, SSO, OAuth2, SAML, MFA    |
| Vault (KV + Transit)    | Azure Key Vault          | Secret and key storage                         |
| SOPS                    | AWS Secrets Manager      | Secure configuration file encryption           |
| MinIO                   | Amazon S3 / Azure Blob   | S3-compatible object storage                   |
| Grafana + Elastic Stack | CloudWatch / Azure Monitor | Centralized monitoring and logging           |
| Duplicati               | Azure Backup / AWS Backup| Scheduled backup and restore                   |
| Nginx Proxy Manager     | Azure App Gateway        | HTTPS routing with auto certificate management |

## 🧪 Who is Clah for?

- Learners who want to **understand infrastructure** by building it
- **Developers** who need a local cloud-like testbed
- **Tinkerers** who want full control over their digital services
- Users seeking a **modular, reproducible**, and fully self-hosted environment

## 🚀 Get Started

Check out the [Quick Start Guide](getting-started.md) to launch your personal home cloud with Clah. Every module is documented with practical examples, ready-to-use scripts, and setup tips.

---

> Clah is a lightweight, real alternative to complex cloud ecosystems—built for self-hosting, digital autonomy, and advanced experimentation.
