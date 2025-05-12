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

if [[ -f "${CLAH_BIN}/load_env.sh" ]]; then
    source "${CLAH_BIN}/load_env.sh"
fi
```
Replace <project-dir> with the path where you cloned the repository.
This configuration will allow you to use the clah command from any terminal session.

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

Alternatively, you can follow this documentation step by step to have full control and understanding of each component in the setup process.

- [Service Config](./sc-install.md)
- [Network](./network.md)
- [Vault](./vault.md)