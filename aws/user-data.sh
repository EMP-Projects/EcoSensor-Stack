#!/bin/bash

# login github docker registry
# export GITHUB_TOKEN=$(aws ssm get-parameter --name /ecosensor/ghcr-token --query Parameter.Value --output text)
export GITHUB_TOKEN=
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Clone repository and build stack
cd $HOME/ecosensor-stack
git pull

# start docker stack
docker compose rm -f
docker compose pull
docker compose --profile all up -d