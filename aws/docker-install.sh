#!/bin/bash

# Update and install packages
sudo apt install -y git docker.io

# -----------------------------------
# Install Docker Compose
sudo usermod -a -G docker ubuntu
id ubuntu
# Reload a Linux user's group assignments to docker w/o logout
newgrp docker

DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.29.6/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

sudo systemctl enable docker.service
sudo systemctl start docker.service
