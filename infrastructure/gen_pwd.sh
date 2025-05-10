#!/bin/bash

RANDOM_PWD=$(pwgen -s 22 1)

echo "{\"random_password\": \"$RANDOM_PWD\"}"


