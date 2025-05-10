## 1. Clone the Repository

Clone the GitHub repository into your preferred project directory:

```bash title="bash"
git clone https://github.com/esposimo/clah.git <project-dir>
```
Replace <project-dir> with the absolute path where you want to store the project files.

## 2. Configure Your Shell Environment

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

## 3. Reload Your Shell Environment

After modifying your shell configuration file, apply the changes by either:

- restarting your shell session (e.g., open a new terminal), or  
- running the following command:

```bash title="bash"
source ~/.bashrc
```
Once reloaded, the clah command should be available in your terminal.

## 4. Initialize the CLAH Environment

Run the following command to initialize the environment:

```bash title="bash"
clah init
```

!!! info
    This command will start the Consul container, which runs on port 15080 of your Docker host.
    If you need to change this port or customize the container setup, refer to the documentation for clah init.


## 5. Access the Dashboard

Once the initialization is complete, your local environment is ready to use.

You can now access the main dashboard at: [http://localhost:9080]([http://localhost:9080])


Replace `localhost` with the IP address or hostname of your NUC if you're accessing it from another machine.
