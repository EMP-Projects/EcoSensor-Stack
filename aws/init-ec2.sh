#!/bin/bash

# Read a parameter from AWS Systems Manager Parameter Store
aws_client_id=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_CLIENT_ID" --query "Parameter.Value" --output text) 
aws_client_secret=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_CLIENT_SECRET" --query "Parameter.Value" --output text) 
aws_region=$(aws ssm get-parameter --name "ECOSENSOR_AWS_REGION" --query "Parameter.Value" --output text) 
aws_topic_arc=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_TOPIC_ARN" --query "Parameter.Value" --output text) 
aws_bucket_name_data=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_BUCKET_NAME_DATA" --query "Parameter.Value" --output text) 
pg_pass=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_PG_PASS" --query "Parameter.Value" --output text) 
pg_pass_osm=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_PG_PASS_OSM" --query "Parameter.Value" --output text) 
pg_pass_istat=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_PG_PASS_ISTA" --query "Parameter.Value" --output text) 
github_token=$(aws ssm get-parameter --with-decryption --name "GITHUB_TOKEN" --query "Parameter.Value" --output text) 

# Export the parameter value as an environment variable
export AWS_TOPIC_ARN="$parameter_value"
export AWS_BUCKET_NAME="$aws_bucket_name_data"
export AWS_ACCESS_KEY_ID="$aws_client_id"
export AWS_SECRET_ACCESS_KEY="$aws_client_secret"
export AWS_DEFAULT_REGION="$aws_region"
export GITHUB_TOKEN="$github_token"

# Backend API
export ECOSENSOR_PORT=80
export ECOSENSOR_OPENMETEO_API=http://localhost:8080

# Database
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=ecosensor
export POSTGRES_PASS="$pg_pass"
export POSTGRES_DB=ecosensor

# Database Istat
export POSTGRES_ISTAT_USER=istat
export POSTGRES_ISTAT_PASS="$pg_pass_istat"
export POSTGRES_ISTAT_DB=istat

# Database Osm2pgsql
export POSTGRES_OSM_USER=osm
export POSTGRES_OSM_PASS="$pg_pass_osm"
export POSTGRES_OSM_DB=osm

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Update and install packages
sudo apt update

# Install Open-Meteo-API, Docker, Istat and Osm2pgsql
sh ./docker-install.sh
sh ./om-install.sh
sh ./istat-install.sh
sh ./osm-install.sh

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
sh ./istat-import.sh $POSTGRES_HOST $POSTGRES_PORT $POSTGRES_ISTAT_USER $POSTGRES_ISTAT_PASS $POSTGRES_ISTAT_DB

# import OSM data
sh ./osm-import.sh $POSTGRES_HOST $POSTGRES_PORT $POSTGRES_OSM_USER $POSTGRES_OSM_PASS $POSTGRES_OSM_DB
