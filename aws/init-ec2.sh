#!/bin/bash

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Read a parameter from AWS Systems Manager Parameter Store
aws_client_id=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_CLIENT_ID" --query "Parameter.Value" --output text) 
aws_client_secret=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_CLIENT_SECRET" --query "Parameter.Value" --output text) 
aws_region=$(aws ssm get-parameter --name "ECOSENSOR_AWS_REGION" --query "Parameter.Value" --output text) 
aws_topic_arc=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_TOPIC_ARN" --query "Parameter.Value" --output text) 
aws_bucket_name_data=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_BUCKET_NAME_DATA" --query "Parameter.Value" --output text) 
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

# Install Open-Meteo-API, Docker, Istat and Osm2pgsql
sh ./docker-install.sh
sh ./om-install.sh
sh ./pg-install.sh

# import Istat data
sh ./istat-install.sh
sh ./istat-import.sh $POSTGRES_HOST $POSTGRES_PORT $POSTGRES_ISTAT_USER $POSTGRES_ISTAT_PASS $POSTGRES_ISTAT_DB

# import OSM data
sh ./osm-install.sh
sh ./osm-import.sh $POSTGRES_HOST $POSTGRES_PORT $POSTGRES_OSM_USER $POSTGRES_OSM_PASS $POSTGRES_OSM_DB
