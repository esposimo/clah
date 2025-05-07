#!/bin/bash

IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')

echo "{\"docker_host_ip\": \"$IP\"}"


