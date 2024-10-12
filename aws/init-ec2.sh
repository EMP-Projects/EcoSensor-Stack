#!/bin/bash

sudo yum update
sudo yum install -y git docker

sudo usermod -a -G docker ec2-user
id ec2-user
# Reload a Linux user's group assignments to docker w/o logout
newgrp docker

DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.29.6/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

sudo systemctl enable docker.service
sudo systemctl start docker.service

# Clone repository and build stack
git clone https://github.com/EMP-Projects/EcoSensor-Stack.git $HOME/ecosensor-stack
cd ecosensor-stack

# Create .env file in the project directory
cat <<EOF > $HOME/ecosensor-stack/.env
ECOSENSOR_PORT=15436
ECOSENSOR_OPENMETEO_API=http://ecosensor-open-meteo-api:8080
AWS_TOPIC_ARN=
AWS_BUCKET_NAME=
POSTGRES_ISTAT_HOST=localhost
POSTGRES_ISTAT_PORT=15434
POSTGRES_ISTAT_USER=istat
POSTGRES_ISTAT_PASS=
POSTGRES_ISTAT_DB=istat
POSTGRES_HOST=localhost
POSTGRES_PORT=15432
POSTGRES_USER=ecosensor
POSTGRES_PASS=
POSTGRES_DB=ecosensor
POSTGRES_SCHEMA=public
OPEN_METEO_MODELS=ncep_gfs013,copernicus_era5,copernicus_dem90,cams_europe
OPEN_METEO_VARIABLES=temperature_2m,precipitation,carbon_monoxide,nitrogen_dioxide,ozone,pm10,pm2_5
OPEN_METEO_MAX_AGE_DAYS=3
OPEN_METEO_REPEAT_INTERVAL=5
OPEN_METEO_CONCURRENT=4
OPEN_METEO_PORT=15434
POSTGRES_OSM_HOST=localhost
POSTGRES_OSM_PORT=15432
POSTGRES_OSM_USER=osm
POSTGRES_OSM_PASS=
POSTGRES_OSM_DB=osm
GITHUB_TOKEN=
EOF