#!/bin/bash

aws_bucket_name_istat=$(aws ssm get-parameter --region us-east-1 --with-decryption --name "ECOSENSOR_AWS_BUCKET_NAME_ISTAT" --query "Parameter.Value" --output text)
export AWS_BUCKET_NAME_ISTAT="$aws_bucket_name_istat"

aws_region=$(aws ssm get-parameter --with-decryption --region us-east-1 --name "ECOSENSOR_AWS_REGION" --query "Parameter.Value" --output text) 
export AWS_DEFAULT_REGION="$aws_region"

# sync bucket s3 with local folder
aws s3 sync --region $AWS_DEFAULT_REGION s3://$AWS_BUCKET_NAME_ISTAT $HOME/istat-data

sudo add-apt-repository ppa:ubuntugis/ppa
sudo apt update
sudo apt -y install gdal-bin python3 python3-venv python3-pip python3-dev libpq-dev 
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install GDAL osmium psycopg2 numpy pandas matplotlib jupyterlab ipython-sql ipython jupyter_contrib_nbextensions geopandas

# Database Istat
export POSTGRES_ISTAT_PASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_ISTAT_PASS" --query "Parameter.Value" --output text)

sudo -u ubuntu psql -c "CREATE USER istat WITH PASSWORD '$POSTGRES_ISTAT_PASS';"
sudo -u ubuntu psql -c "CREATE DATABASE istat OWNER istat;"
sudo -u ubuntu psql -c "GRANT ALL PRIVILEGES ON DATABASE istat TO istat;"

sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" -d istat
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" -d istat
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;" -d istat

# se la cartella geojson non esiste la crea
if [ ! -d "geojson" ]
then
    echo "Non trovo la cartella geojson"
    exit
fi

# legge tutti i file .geojson e li importa nel database
for file in geojson/*.geojson
do
    # estrae il nome del file
    table=$(basename $file .geojson)
    
    ogr2ogr -nlt PROMOTE_TO_MULTI -nln $table PG:"host=localhost port=5432 user=istat password=$POSTGRES_ISTAT_PASS dbname=istat" $file -f "PostgreSQL" -overwrite -s_srs EPSG:4326 -t_srs EPSG:3857 
    
    # stampa a video il nome del file importato
    echo "Importato il file $file"
done


