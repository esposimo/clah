data "external" "docker_host_ip" {
  program = ["${path.cwd}/get_docker_ip.sh"]
}