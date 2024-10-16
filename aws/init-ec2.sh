#!/bin/bash

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Open-Meteo-API, Docker, Istat and Osm2pgsql
sudo sh ./docker-install.sh
sudo sh ./om-install.sh
sudo sh ./pg-install.sh
