#!/bin/bash
sudo yum update
sudo yum install -y git yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker


# export ENV variables
# istat container
export POSTGRES_ISTAT_HOST=localhost
export POSTGRES_ISTAT_PORT=15434
export POSTGRES_ISTAT_USER=istat
export POSTGRES_ISTAT_PASS=
export POSTGRES_ISTAT_DB=istat

# backend container
export ECOSENSOR_PORT=15435
export ECOSENSOR_OPENMETEO_API=http://ecosensor-open-meteo-api:8080

# database
export POSTGRES_HOST=localhost
export POSTGRES_PORT=15432
export POSTGRES_USER=ecosensor
export POSTGRES_PASS=
export POSTGRES_VERSION_TAG=16-3.4
export POSTGRES_DB=ecosensor
export POSTGRES_SCHEMA=public

# open-meteo
export OPEN_METEO_MODELS=ncep_gfs013,copernicus_era5,copernicus_dem90,cams_europe
export OPEN_METEO_VARIABLES=temperature_2m,precipitation,carbon_monoxide,nitrogen_dioxide,ozone,pm10,pm2_5
export OPEN_METEO_MAX_AGE_DAYS=3
export OPEN_METEO_REPEAT_INTERVAL=5
export OPEN_METEO_CONCURRENT=4
export OPEN_METEO_PORT=15434

# Database Osm
export POSTGRES_OSM_HOST=localhost
export POSTGRES_OSM_PORT=15432
export POSTGRES_OSM_USER=osm
export POSTGRES_OSM_PASS=
export POSTGRES_OSM_VERSION_TAG=16-3.4
export POSTGRES_OSM_DB=osm
export POSTGRES_SCHEMA=public