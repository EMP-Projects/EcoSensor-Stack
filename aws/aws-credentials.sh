#!/bin/bash

# Read a parameter from AWS Systems Manager Parameter Store
aws_client_id=$(aws ssm get-parameter --with-decryption --region us-east-1 --name "ECOSENSOR_AWS_CLIENT_ID" --query "Parameter.Value" --output text) 
aws_client_secret=$(aws ssm get-parameter --with-decryption --region us-east-1 --name "ECOSENSOR_AWS_CLIENT_SECRET" --query "Parameter.Value" --output text) 
aws_region=$(aws ssm get-parameter --region us-east-1 --name "ECOSENSOR_AWS_REGION" --query "Parameter.Value" --output text) 

# Create the .aws directory if it doesn't exist
mkdir -p ~/.aws

# Create the credentials file with the necessary content
cat <<EOL > ~/.aws/credentials
[default]
aws_access_key_id=$aws_client_id
aws_secret_access_key=$aws_client_secret
region=$aws_region
EOL

cat <<EOL > ~/.aws/config
[default]
region=$aws_region
output=json
EOL

# Set appropriate permissions for the credentials file
chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config