#!/bin/bash

# Create a file to store environment variables
ENV_FILE=~/.ecosensor_rc

# Check if the environment file exists, if so, delete it
if [ -f "$ENV_FILE" ]; then
    rm "$ENV_FILE"
fi

# Write environment variables to the file
export PGHOST=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_HOST" --query "Parameter.Value" --output text)
export PGPASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PASS" --query "Parameter.Value" --output text)
export ECODB=$(aws ssm get-parameter --region us-east-1 --profile default --name "ECOSENSOR_DB" --query "Parameter.Value" --output text)
export TOPICARN=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_AWS_TOPIC_ARN" --query "Parameter.Value" --output text)
export BUCKETDATA=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_AWS_BUCKET_NAME_DATA" --query "Parameter.Value" --output text)

echo "Getting the IP of the EC2 instance with the name openmeteo-server"

# Install jq if not already installed
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# Invoke the Lambda function
aws lambda invoke \
    --function-name ec2_ip \
    --payload "$(echo -n "{\"Name\": \"openmeteo-server\"}" | base64)" \
    response.json

# Get the IP from the response
IP=$(jq -r '.body' response.json)
echo $IP

export ECOSENSOR_OPENMETEO_API=$IP

# Clean up
rm response.json

# Set the OPENMETEO environment variable persistently
echo "export ECOSENSOR_OPENMETEO_API=$IP" >> $ENV_FILE
echo "export POSTGRES_HOST=$PGHOST" >> $ENV_FILE
echo "export POSTGRES_PASS=$PGPASS" >> $ENV_FILE
echo "export POSTGRES_USER=postgres" >> $ENV_FILE
echo "export POSTGRES_PORT=5432" >> $ENV_FILE
echo "export POSTGRES_DB=$ECODB" >> $ENV_FILE
echo "export POSTGRES_OSM_HOST=$PGHOST" >> $ENV_FILE
echo "export POSTGRES_OSM_PASS=$PGPASS" >> $ENV_FILE
echo "export POSTGRES_OSM_USER=postgres" >> $ENV_FILE
echo "export POSTGRES_OSM_PORT=5432" >> $ENV_FILE
echo "export POSTGRES_OSM_DB=$ECODB" >> $ENV_FILE
echo "export POSTGRES_ISTAT_HOST=$PGHOST" >> $ENV_FILE
echo "export POSTGRES_ISTAT_PASS=$PGPASS" >> $ENV_FILE
echo "export POSTGRES_ISTAT_USER=postgres" >> $ENV_FILE
echo "export POSTGRES_ISTAT_PORT=5432" >> $ENV_FILE
echo "export POSTGRES_ISTAT_DB=$ECODB" >> $ENV_FILE
echo "export AWS_TOPIC_ARN=$TOPICARN" >> $ENV_FILE
echo "export AWS_BUCKET_NAME=$BUCKETDATA" >> $ENV_FILE

source ~/.bashrc