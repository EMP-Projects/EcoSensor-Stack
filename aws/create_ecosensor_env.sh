#!/bin/bash

export PGHOST=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_HOST" --query "Parameter.Value" --output text)
export PGPASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PASS" --query "Parameter.Value" --output text)
export AWS_BUCKET_NAME_ISTAT=$(aws ssm get-parameter --region us-east-1 --with-decryption --name "ECOSENSOR_AWS_BUCKET_NAME_ISTAT" --query "Parameter.Value" --output text)
export POSTGRES_HOST=$PGHOST
export POSTGRES_PASS=$PGPASS
export POSTGRES_USER=postgres
export POSTGRES_PORT=5432
export POSTGRES_DB=postgres
export POSTGRES_OSM_HOST=$PGHOST
export POSTGRES_OSM_PASS=$PGPASS
export POSTGRES_OSM_USER=postgres
export POSTGRES_OSM_PORT=5432
export POSTGRES_OSM_DB=postgres
export POSTGRES_ISTAT_HOST=$PGHOST
export POSTGRES_ISTAT_PASS=$PGPASS
export POSTGRES_ISTAT_USER=postgres
export POSTGRES_ISTAT_PORT=5432
export POSTGRES_ISTAT_DB=postgres
export AWS_TOPIC_ARN=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_AWS_TOPIC_ARN" --query "Parameter.Value" --output text)
export AWS_BUCKET_NAME=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_AWS_BUCKET_NAME_DATA" --query "Parameter.Value" --output text)

# echo "export POSTGRES_HOST=$PGHOST" >> ~/.bashrc
# echo "export POSTGRES_PASS=$PGPASS" >> ~/.bashrc
# echo "export POSTGRES_USER=postgres" >> ~/.bashrc
# echo "export POSTGRES_PORT=5432" >> ~/.bashrc
# echo "export POSTGRES_DB=postgres" >> ~/.bashrc
# echo "export POSTGRES_OSM_HOST=$PGHOST" >> ~/.bashrc
# echo "export POSTGRES_OSM_PASS=$PGPASS" >> ~/.bashrc
# echo "export POSTGRES_OSM_USER=postgres" >> ~/.bashrc
# echo "export POSTGRES_OSM_PORT=5432" >> ~/.bashrc
# echo "export POSTGRES_OSM_DB=postgres" >> ~/.bashrc
# echo "export POSTGRES_ISTAT_HOST=$PGHOST" >> ~/.bashrc
# echo "export POSTGRES_ISTAT_PASS=$PGPASS" >> ~/.bashrc
# echo "export POSTGRES_ISTAT_USER=postgres" >> ~/.bashrc
# echo "export POSTGRES_ISTAT_PORT=5432" >> ~/.bashrc
# echo "export POSTGRES_ISTAT_DB=postgres" >> ~/.bashrc
# echo "export AWS_TOPIC_ARN=$TOPICARN" >> ~/.bashrc
# echo "export AWS_BUCKET_NAME=$BUCKETDATA" >> ~/.bashrc
# source ~/.bashrc