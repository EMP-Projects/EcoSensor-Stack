#!/bin/bash

export AWS_DEFAULT_REGION=eu-east-1
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

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

# Install Open-Meteo-API, Docker, Istat and Osm2pgsql
exec ./aws/docker-install.sh
exec ./aws/om-install.sh
exec ./aws/istat-install.sh
exec ./aws/osm-install.sh

# -----------------------------------
# Install and configure postgresql
sudo apt update
sudo apt install -y postgresql postgresql-client postgis

# create user and database
sudo -u postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASS';"
sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_DB OWNER $POSTGRES_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;"

sudo -u postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_OSM_PASS';"
sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_OSM_DB OWNER $POSTGRES_OSM_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_OSM_DB TO $POSTGRES_OSM_USER;"

sudo -u postgres psql -c "CREATE USER $POSTGRES_ISTAT_USER WITH PASSWORD '$POSTGRES_ISTAT_PASS';"
sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_ISTAT_DB OWNER $POSTGRES_ISTAT_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_ISTAT_DB TO $POSTGRES_ISTAT_USER;"

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

# import Istat data
exec ./aws/istat-import.sh $POSTGRES_HOST $POSTGRES_PORT $POSTGRES_ISTAT_USER $POSTGRES_ISTAT_PASS $POSTGRES_ISTAT_DB

# import OSM data
exec ./aws/osm-import.sh $POSTGRES_HOST $POSTGRES_PORT $POSTGRES_OSM_USER $POSTGRES_OSM_PASS $POSTGRES_OSM_DB
