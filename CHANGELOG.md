# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

## [0.1.0] 2026-02-09

### Added
- auto `short-env` (first letter) information when environment is created

### Removed
- removed `bin/tf.sh`
- removed useless comments in `consul-service-config.sh`
- removed `force_destroy` params in run-application module for `docker_volume` resource
- removed wrong source `consul-service-config.sh`

### Fixed
- Persistenza dati Consul (rimozione dev mode)
- Configurazione `data_dir` tramite HCL
- Terraform Provider docker name and version

### Changed
- use custom entrypoint for `consul` image
- enable ui in `consul.hcl` config file
- networks name does not have environment prefix
