#!/bin/bash

sudo add-apt-repository -y ppa:ubuntugis/ppa
sudo apt update
sudo apt -y install gdal-bin python3 python3-venv python3-pip python3-dev libpq-dev postgresql
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install GDAL osmium psycopg2 numpy pandas matplotlib jupyterlab ipython-sql ipython jupyter_contrib_nbextensions geopandas

# Database Istat
export PGHOST=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PGHOST" --query "Parameter.Value" --output text)
export PGPASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_ISTAT_PASS" --query "Parameter.Value" --output text)

sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE SCHEMA IF NOT EXISTS istat;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA istat;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA istat;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA istat;"

aws_bucket_name_istat=$(aws ssm get-parameter --region us-east-1 --with-decryption --name "ECOSENSOR_AWS_BUCKET_NAME_ISTAT" --query "Parameter.Value" --output text)
export AWS_BUCKET_NAME_ISTAT="$aws_bucket_name_istat"

aws_region=$(aws ssm get-parameter --with-decryption --region us-east-1 --name "ECOSENSOR_AWS_REGION" --query "Parameter.Value" --output text) 
export AWS_DEFAULT_REGION="$aws_region"

# sync bucket s3 with local folder
aws s3 sync --region $AWS_DEFAULT_REGION s3://$AWS_BUCKET_NAME_ISTAT $HOME/istat-data

# crea la cartella istat-data se non esiste
if [ ! -d "$HOME/istat-data" ]; then
    mkdir -p "$HOME/istat-data"
    echo "Creata la cartella $HOME/istat-data"
fi

# se la cartella geojson non esiste la crea
if [ ! -d "istat-data" ]
then
    echo "Non trovo la cartella istat-data"
    exit
fi

# legge tutti i file .geojson e li importa nel database
for file in istat-data/*.geojson
do
    # estrae il nome del file
    table=$(basename $file .geojson)
    
    ogr2ogr -nlt PROMOTE_TO_MULTI -nln $table PG:"host=$PGHOST port=5432 user=postgres password=$PGPASS dbname=postgres" $file -f "PostgreSQL" -overwrite -s_srs EPSG:4326 -t_srs EPSG:3857 
    
    # stampa a video il nome del file importato
    echo "Importato il file $file"
done