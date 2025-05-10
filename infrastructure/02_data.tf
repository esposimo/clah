data "external" "docker_host_ip" {
  program = ["${path.cwd}/get_docker_ip.sh"]
}

data "external" "random_password" {
  # pwgen -s 22 1
  program = ["${path.cwd}/gen_pwd.sh"]
}