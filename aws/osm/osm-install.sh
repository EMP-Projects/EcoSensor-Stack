#!/bin/bash

sudo add-apt-repository -y ppa:ubuntugis/ppa
sudo apt update
sudo apt install -y git cmake make g++ libboost-dev libbz2-dev zlib1g-dev libpq-dev libproj-dev \
    lua5.3 liblua5.3-dev libgeos-dev libgeos++-dev libprotobuf-c-dev \
    libosmpbf-dev libgdal-dev libjson-c-dev libpng-dev libtiff-dev \
    libicu-dev libxml2-dev libzip-dev liblua5.3-dev libluajit-5.1-dev \
    libprotobuf-c-dev libgeos-dev libgeos++-dev libgdal-dev libjson-c-dev \
    libpng-dev libtiff-dev libicu-dev libproj-dev libxml2-dev libzip-dev \
    python3 python3-pip python3-venv \
    gdal-bin python3 python3-venv python3-pip python3-dev libpq-dev osm2pgsql

# Database Osm2pgsql
export PGHOST=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_HOST" --query "Parameter.Value" --output text)
export PGPASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_PASS" --query "Parameter.Value" --output text)

# add extension postgis to the database
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS hstore;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS pgrouting;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;"
sudo -u postgres psql postgresql://postgres:$PGPASS@$PGHOST:5432/postgres -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"

echo DATADIR="${DATADIR:="$HOME/osm"}"
if [[ ! -d "$DATADIR" ]]; then
    echo "Directory $DATADIR does not exist. Creating..."
    mkdir -p "$DATADIR"
fi
echo PBF="${PBF:=$DATADIR/italy-latest.osm.pbf}"
echo URLOSM="https://download.geofabrik.de/europe/italy-latest.osm.pbf"

if [[ -f "$PBF" ]]; then
    echo "Using local file at $PBF"
else
    echo "$PBF File not found, downloading..."
    wget -O "${PBF}" https://download.geofabrik.de/europe/italy-latest.osm.pbf 

    while [ ! -f "$PBF" ]; do
        echo "Waiting for download to complete..."
        sleep 5
    done

    chmod 777 "${PBF}"
fi

export PGPASSWORD=$PGPASS

if psql --no-password -h "$PGHOST" -U postgres -d postgres -p 5432 -c "select * from osm2pgsql_properties;"; then
    echo "Updating."
    osm2pgsql-replication update \
        -v \
        -H $PGHOST \
        -d postgres \
        -U postgres \
        -P 5432 \
        -- -j \
        -S $HOME/osm/custom.style \
        -x
else
    echo "Database not ready, need to initialize. Creating extensions ..."

    osm2pgsql -v \
    -j \
    -c \
    -s \
    -C 4000 \
    -x \
    -S $HOME/osm/custom.style \
    -H $PGHOST \
    -d postgres \
    -U postgres \
    -P 5432 \
    "$PBF"

    osm2pgsql-replication init \
        -H $PGHOST \
        -d postgres \
        -U postgres \
        -P 5432 \
        --osm-file "$PBF"
fi