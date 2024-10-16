#!/bin/bash

aws_bucket_name_istat=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_BUCKET_NAME_ISTAT" --query "Parameter.Value" --output text)
export AWS_BUCKET_NAME_ISTAT="$aws_bucket_name_istat"

aws_region=$(aws ssm get-parameter --with-decryption --name "ECOSENSOR_AWS_REGION" --query "Parameter.Value" --output text) 
export AWS_DEFAULT_REGION="$aws_region"

# sync bucket s3 with local folder
aws s3 sync --region $AWS_DEFAULT_REGION s3://$AWS_BUCKET_NAME_ISTAT $HOME/istat-data

sudo add-apt-repository ppa:ubuntugis/ppa
sudo apt update
sudo apt -y install gdal-bin python3 python3-venv python3-pip python3-dev libpq-dev 
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install GDAL osmium psycopg2 numpy pandas matplotlib jupyterlab ipython-sql ipython jupyter_contrib_nbextensions geopandas