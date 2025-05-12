# System Requirements

The CLAH environment is designed to run on a **Debian-based system** (e.g., Debian, Ubuntu).  
Before proceeding, ensure your system meets the following requirements.

## Hardware Requirements

The CLAH platform has been tested and verified on the following hardware configuration:

| Component        | Specification                                     |
|------------------|--------------------------------------------------|
| **Device**       | Mini PC (e.g., [NiPoGi N95 Mini PC](https://www.amazon.it/Mini-Alder-Lake-N95-generazione-Dual-Band/dp/B0CRH8SFX7)) |
| **CPU**          | Intel N95 (4 cores, 4 threads, up to 3.4 GHz)     |
| **RAM**          | 16 GB DDR4                                        |
| **Storage**      | 512 GB M.2 SATA SSD                               |
| **Operating System** | Debian 12.1 (Bookworm)                        |


This configuration provides enough resources to run the full CLAH infrastructure stack, including all services such as the API gateway, Vault, Service Config, and monitoring tools.

!!! note
    While the system can run on lower specs, using hardware similar to this configuration is strongly recommended for performance and stability.

## Required Tools

The following tools and packages must be installed:

- [Docker](https://docs.docker.com/engine/install/)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [SOPS](https://github.com/getsops/sops)
- System Utilities (git, curl, jq, pwgen)

---

## Installation Guide

### Install System Utilities

**Clah needs the following system utilities for essential operations:**

- **git** – used to clone the CLAH repository
- **curl** – required for making HTTP requests to the service configuration endpoint.  
- **jq** – used to parse and manipulate JSON data in shell scripts.
- **pwgen** – used to generate random and secure passwords when provisioning services.

```bash title="bash"
sudo apt install git curl jq pwgen
```

## External Tools Installation

Clah needs the following external tools that are not installed via `apt`.
Please refer to their respective official documentation for installation instructions:

- **Docker**  
  [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)

- **SOPS (Mozilla SOPS)**  
  [https://github.com/getsops/sops#installation](https://github.com/getsops/sops#installation)

- **Terraform (by HashiCorp)**  
  [https://developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install)

### **Recommended settings for docker**

- **Limit container log size and rotation** to prevent uncontrolled disk growth.  
    Refer to the Docker documentation on configuring the `json-file` [logging driver](https://docs.docker.com/engine/logging/drivers/json-file/).