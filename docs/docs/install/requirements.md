# System Requirements

The CLAH environment is designed to run on a **Debian-based system** (e.g., Debian, Ubuntu).  
Before proceeding, ensure your system meets the following requirements.

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