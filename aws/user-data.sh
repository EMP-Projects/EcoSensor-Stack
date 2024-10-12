#!/bin/bash

# Create .env file in the home directory
cat <<EOF > ~/.env
ECOSENSOR_PORT=15436
ECOSENSOR_OPENMETEO_API=http://ecosensor-open-meteo-api:8080
AWS_TOPIC_ARN=
AWS_BUCKET_NAME=
POSTGRES_ISTAT_HOST=localhost
POSTGRES_ISTAT_PORT=15434
POSTGRES_ISTAT_USER=istat
POSTGRES_ISTAT_PASS=
POSTGRES_ISTAT_DB=istat
ECOSENSOR_PORT=15435
ECOSENSOR_OPENMETEO_API=http://ecosensor-open-meteo-api:8080
AWS_TOPIC_ARN=
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
EOF

sudo yum update
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
sudo yum install -y git yum-utils docker

sudo usermod -a -G docker ec2-user
id ec2-user
# Reload a Linux user's group assignments to docker w/o logout
newgrp docker

sudo wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose

sudo systemctl enable docker.service
sudo systemctl start docker.service

# Clone repository and build stack
git clone https://github.com/EMP-Projects/EcoSensor-Stack.git ~/ecosensor-stack
cd ecosensor-stack

docker-compose rm -f
docker-compose pull
docker-compose up -d