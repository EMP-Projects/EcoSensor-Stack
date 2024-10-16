#!/bin/bash

# Database
export POSTGRES_USER=ecosensor
export POSTGRES_PASS=$(aws ssm get-parameter --with-decryption --profile default --name "ECOSENSOR_PG_PASS" --query "Parameter.Value" --output text)
export POSTGRES_DB=ecosensor

# Database Istat
export POSTGRES_ISTAT_USER=istat
export POSTGRES_ISTAT_PASS=$(aws ssm get-parameter --with-decryption --profile default --name "ECOSENSOR_ISTAT_PASS" --query "Parameter.Value" --output text)
export POSTGRES_ISTAT_DB=istat

# Database Osm2pgsql
export POSTGRES_OSM_USER=osm
export POSTGRES_OSM_PASS=$(aws ssm get-parameter --with-decryption --profile default --name "ECOSENSOR_OSM_PASS" --query "Parameter.Value" --output text) 
export POSTGRES_OSM_DB=osm

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
sudo sh ./istat-install.sh
sudo sh ./istat-import.sh localhost 5432 $POSTGRES_ISTAT_USER $POSTGRES_ISTAT_PASS $POSTGRES_ISTAT_DB

# import OSM data
sudo sh ./osm-install.sh
sudo sh ./osm-import.sh localhost 5432 $POSTGRES_OSM_USER $POSTGRES_OSM_PASS $POSTGRES_OSM_DB