#!/bin/bash

args="$@"
sudo docker compose --file='/home/ubuntu/pipelineboy/iac/docker-compose.iac.yml' run --rm kubectl $args