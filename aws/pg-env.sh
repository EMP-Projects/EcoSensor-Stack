#!/bin/bash

pg_pass=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PG_PASS" --query "Parameter.Value" --output text) 
pg_pass_osm=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PG_PASS_OSM" --query "Parameter.Value" --output text) 
pg_pass_istat=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PG_PASS_ISTA" --query "Parameter.Value" --output text) 

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