#!/bin/bash

# Database
export POSTGRES_PASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PG_PASS" --query "Parameter.Value" --output text)

# -----------------------------------
# Install and configure postgresql
sudo apt update
sudo apt install -y postgresql postgresql-client postgis

# create user and database
sudo -u ubuntu psql -c "CREATE USER ecosensor WITH PASSWORD '$POSTGRES_PASS';"
sudo -u ubuntu psql -c "CREATE DATABASE ecosensor OWNER ecosensor;"
sudo -u ubuntu psql -c "GRANT ALL PRIVILEGES ON DATABASE ecosensor TO ecosensor;"

sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" -d ecosensor
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" -d ecosensor
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS pgrouting;" -d ecosensor
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;" -d ecosensor
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;" -d ecosensor

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