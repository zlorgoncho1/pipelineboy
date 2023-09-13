#!/bin/bash

args="$@"
sudo docker compose --file='/home/ubuntu/pipelineboy/iac/docker-compose.iac.yml' run --rm terraform $args