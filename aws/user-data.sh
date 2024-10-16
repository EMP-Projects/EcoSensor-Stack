#!/bin/bash

github_token=$(aws ssm get-parameter --with-decryption --profile default --name "GITHUB_TOKEN" --query "Parameter.Value" --output text)
github_username=$(aws ssm get-parameter --with-decryption --profile default --name "GITHUB_USERNAME" --query "Parameter.Value" --output text)

export GITHUB_TOKEN=$github_token
export GITHUB_USERNAME=$github_username

if [ -d "$HOME/ecosensor-stack" ]; then
    echo "Directory $HOME/ecosensor-stack already exists."
    cd ecosensor-stack
    git pull
else
    # Clone repository and build stack
    git clone https://github.com/EMP-Projects/EcoSensor-Stack.git $HOME/ecosensor-stack
fi

# login github docker registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# start docker stack
docker compose rm -f
docker compose pull
docker compose --profile all up -d