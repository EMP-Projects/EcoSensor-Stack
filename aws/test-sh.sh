#!/bin/bash

# Read a parameter from AWS Systems Manager Parameter Store
parameter_value=$(aws ssm get-parameter --with-decryption --region us-east-1 --name "MY_VAR" --query "Parameter.Value" --output text) 

# Export the parameter value as an environment variable
export MY_STRING_PARAMETER="$parameter_value"

echo "MY_STRING_PARAMETER=$MY_STRING_PARAMETER"
