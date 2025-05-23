## Clone the Repository

Clone the GitHub repository into your preferred project directory:

```bash title="bash"
git clone https://github.com/esposimo/clah.git <project-dir>
```
Replace <project-dir> with the absolute path where you want to store the project files.

## Configure Your Shell Environment

Modify your `~/.bashrc` (or equivalent shell config file, e.g., `~/.zshrc`) to set the required environment variables:

```bash title="bash" linenums="1"
# add environment variable
export CLAH_HOME="<project-dir>"
export CLAH_BIN="${CLAH_HOME}/bin"
export CLAH_SC_PORT="15080"
export CLAH_DATA="<project-data>"

if [[ -f "${CLAH_BIN}/load_env.sh" ]]; then
    source "${CLAH_BIN}/load_env.sh"
fi
```
Replace <project-dir> with the path where you cloned the repository.
This configuration will allow you to use the clah command from any terminal session.

!!! info
    You can change the `CLAH_SC_HOST_PORT` variable to initialize the Service Config on a port other than `15080`. This won't affect any of the CLAH Terraform projects.
    Since **CLAH** runs only with Docker in single-node mode, the Terraform projects will always use `127.0.0.1:CLAH_SC_HOST_PORT` as the endpoint.


## Reload Your Shell Environment

After modifying your shell configuration file, apply the changes by either:

- restarting your shell session (e.g., open a new terminal), or  
- running the following command:

```bash title="bash"
source ~/.bashrc
```
Once reloaded, the clah command should be available in your terminal.

## Quick Start

You can initialize the entire CLAH infrastructure with a single command:

```bash
clah init all
```
This command will automatically execute all the required steps in the correct order, using the default configuration files.

!!! tip
    The `clah init all` command is intended for users who want a ready-to-use setup with default values.
    If you prefer to customize the configuration or understand how CLAH works internally, follow each section in this documentation manually.

Step by step documentation to have full control and understanding each component in the setup process

- [Service Config](./sc-install.md)
- [Network](./network.md)
- [Vault](./vault.md)