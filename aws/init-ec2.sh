#!/bin/bash

# Database
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=ecosensor
export POSTGRES_PASS=
export POSTGRES_DB=ecosensor

# Database Istat
export POSTGRES_ISTAT_USER=istat
export POSTGRES_ISTAT_PASS=
export POSTGRES_ISTAT_DB=istat

# Database Osm2pgsql
export POSTGRES_OSM_USER=osm
export POSTGRES_OSM_PASS=
export POSTGRES_OSM_DB=osm

# Update and install packages
sudo apt update
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

# -----------------------------------
# Install Open-Meteo-API
sudo mkdir $HOME/.gnupg
sudo gpg --keyserver hkps://keys.openpgp.org --no-default-keyring --keyring /usr/share/keyrings/openmeteo-archive-keyring.gpg  --recv-keys E6D9BD390F8226AE
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmeteo-archive-keyring.gpg] https://apt.open-meteo.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/openmeteo-api.list

sudo apt update
sudo apt install -y openmeteo-api

# Download the latest ECMWF IFS 0.4° open-data forecast for temperature (50 MB)
sudo chown -R $(id -u):$(id -g) /var/lib/openmeteo-api
cd /var/lib/openmeteo-api
openmeteo-api sync ncep_gfs013,copernicus_era5,copernicus_dem90,cams_europe temperature_2m,precipitation,carbon_monoxide,nitrogen_dioxide,ozone,pm10,pm2_5

sudo systemctl status openmeteo-api
sudo systemctl restart openmeteo-api
sudo journalctl -u openmeteo-api.service

# -----------------------------------
# Install and configure postgresql
sudo apt update
sudo apt install -y postgresql postgresql-client postgis

# add extension postgis to the database
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" -d $POSTGRES_OSM_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" -d $POSTGRES_OSM_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS pgrouting;" -d $POSTGRES_OSM_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;" -d $POSTGRES_OSM_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;" -d $POSTGRES_OSM_DB

sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" -d $POSTGRES_ISTAT_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" -d $POSTGRES_ISTAT_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;" -d $POSTGRES_ISTAT_DB

sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" -d $POSTGRES_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" -d $POSTGRES_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS pgrouting;" -d $POSTGRES_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;" -d $POSTGRES_DB
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;" -d $POSTGRES_DB

# dimmi il comando per aggiungere queste opzioni di configurazione a postgresql.conf
# add configuration options to postgresql.conf
echo "shared_buffers=1GB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "work_mem=50MB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "maintenance_work_mem=2GB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "autovacuum_work_mem=1GB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "wal_level=minimal" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "checkpoint_completion_target=0.9" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "max_wal_senders=0" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "random_page_cost=1.0" | sudo tee -a /etc/postgresql/14/main/postgresql.conf

# restart postgresql
sudo systemctl restart postgresql
