#!/bin/bash

# Database
export POSTGRES_PASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PG_PASS" --query "Parameter.Value" --output text)
export ECOSENSORDB=$(aws ssm get-parameter --region us-east-1 --profile default --name "ECOSENSOR_DB" --query "Parameter.Value" --output text)

# -----------------------------------
# Install and configure postgresql
sudo apt update
sudo apt install -y postgresql postgresql-client postgis

# restart postgresql
sudo systemctl restart postgresql

# create user and database
sudo -u postgres psql -c "CREATE USER $ECOSENSORDB WITH PASSWORD '$POSTGRES_PASS';"
sudo -u postgres psql -c "CREATE DATABASE $ECOSENSORDB OWNER $ECOSENSORDB;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $ECOSENSORDB TO $ECOSENSORDB;"

sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" -d ecosensor
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" -d ecosensor
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS pgrouting;" -d ecosensor
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;" -d ecosensor
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;" -d ecosensor

# dimmi il comando per aggiungere queste opzioni di configurazione a postgresql.conf
# add configuration options to postgresql.conf
sudo echo "shared_buffers=512MB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
sudo echo "work_mem=50MB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
sudo echo "maintenance_work_mem=512MB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
sudo echo "autovacuum_work_mem=512MB" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
sudo echo "wal_level=minimal" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
sudo echo "checkpoint_completion_target=0.9" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
sudo echo "max_wal_senders=0" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
sudo echo "random_page_cost=1.0" | sudo tee -a /etc/postgresql/14/main/postgresql.conf

