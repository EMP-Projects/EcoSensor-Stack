#!/bin/bash

sudo add-apt-repository ppa:ubuntugis/ppa
sudo apt update
sudo apt -y install git cmake make g++ libboost-dev libbz2-dev zlib1g-dev libpq-dev libproj-dev \
    lua5.3 liblua5.3-dev libgeos-dev libgeos++-dev libprotobuf-c-dev \
    libosmpbf-dev libgdal-dev libjson-c-dev libpng-dev libtiff-dev \
    libicu-dev libxml2-dev libzip-dev liblua5.3-dev libluajit-5.1-dev \
    libprotobuf-c-dev libgeos-dev libgeos++-dev libgdal-dev libjson-c-dev \
    libpng-dev libtiff-dev libicu-dev libproj-dev libxml2-dev libzip-dev \
    python3 python3-pip python3-venv nlohmann-json \
    boost expat bzip2 zlib libpq proj lua5.3 luajit potrace opencv lz4-libs 
sudo apt -y install gdal-bin python3 python3-venv python3-pip python3-dev libpq-dev 

git clone git clone -b 1.10.0 https://github.com/osm2pgsql-dev/osm2pgsql.git $HOME/osm2pgsql
cd $HOME/osm2pgsql
mkdir build
cd build
sudo make
sudo make install
sudo make install-gen

# installa le librerie per la compilazione di osm2pgsql
python3 -m venv /venv
export PATH="/venv/bin:$PATH"
pip install osmium psycopg2

# Database Osm2pgsql
export POSTGRES_OSM_PASS=$(aws ssm get-parameter --with-decryption --region us-east-1 --profile default --name "ECOSENSOR_OSM_PASS" --query "Parameter.Value" --output text) 

sudo -u ubuntu psql -c "CREATE USER osm WITH PASSWORD '$POSTGRES_OSM_PASS';"
sudo -u ubuntu psql -c "CREATE DATABASE osm OWNER osm;"
sudo -u ubuntu psql -c "GRANT ALL PRIVILEGES ON DATABASE osm TO osm;"


# add extension postgis to the database
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" -d osm
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" -d osm
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS pgrouting;" -d osm
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;" -d osm
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;" -d osm

echo DATADIR="${DATADIR:="/osm"}"
echo PBF="${PBF:=$DATADIR/italy-latest.osm.pbf}"

echo URLOSM="https://download.geofabrik.de/europe/italy-latest.osm.pbf"

if [[ -f "$PBF" ]]; then
    echo "Using local file at $PBF"
else
    echo "$PBF File not found, downloading..."
    exec wget -O "${PBF}" https://download.geofabrik.de/europe/italy-latest.osm.pbf 
    exec chmod 777 "${PBF}"
fi

osm2pgsql -v \
    -j \
    -c \
    -s \
    -C 4000 \
    -x \
    -S /usr/local/share/osm2pgsql/custom.style \
    -H localhost \
    -d osm \
    -U osm \
    -P 5432 \
    "$PBF"

osm2pgsql-replication init \
    -H localhost \
    -d osm \
    -U osm \
    -P 5432 \
    --osm-file "$PBF"