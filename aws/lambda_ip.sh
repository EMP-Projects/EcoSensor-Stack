#!/bin/bash

param_ec2_instance_name=$1 

echo "Getting the IP of the EC2 instance with the name $param_ec2_instance_name"

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
    --payload "$(echo -n "{\"Name\": \"$param_ec2_instance_name\"}" | base64)" \
    response.json

# Get the IP from the response
IP=$(jq -r '.body' response.json)
echo $IP

export ECOSENSOR_OPENMETEO_API=$IP

# Clean up
rm response.json

# Set the OPENMETEO environment variable persistently
echo "export ECOSENSOR_OPENMETEO_API=$IP" >> ~/.bashrc
source ~/.bashrc
echo "ECOSENSOR_OPENMETEO_API is set to $ECOSENSOR_OPENMETEO_API"

