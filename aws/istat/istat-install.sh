#!/bin/bash
sudo apt update
sudo apt -y install osmium-tool gdal-bin python3 python3-venv python3-pip python3-dev libpq-dev postgresql

# Database Istat
export PGHOST=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_HOST" --query "Parameter.Value" --output text)
export PGPASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PASS" --query "Parameter.Value" --output text)

sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS hstore;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"

export AWS_BUCKET_NAME_ISTAT=$(aws ssm get-parameter --region us-east-1 --with-decryption --name "ECOSENSOR_AWS_BUCKET_NAME_ISTAT" --query "Parameter.Value" --output text)

# sync bucket s3 with local folder
aws s3 sync --region us-east-1 s3://$AWS_BUCKET_NAME_ISTAT $HOME/istat-data

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