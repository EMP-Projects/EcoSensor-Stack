#!/bin/bash

if [ -d "$HOME/ecosensor-stack" ]; then
    echo "Directory $HOME/ecosensor-stack already exists."
    cd ecosensor-stack
    git pull
else
    # Clone repository and build stack
    git clone https://github.com/EMP-Projects/EcoSensor-Stack.git $HOME/ecosensor-stack
fi

# Create .env file in the project directory
cat <<EOF > $HOME/ecosensor-stack/.env
ECOSENSOR_PORT=80
ECOSENSOR_OPENMETEO_API=http://ecosensor-open-meteo-api:8080
AWS_TOPIC_ARN=
AWS_BUCKET_NAME=
POSTGRES_ISTAT_HOST=localhost
POSTGRES_ISTAT_PORT=15434
POSTGRES_ISTAT_USER=istat
POSTGRES_ISTAT_PASS=
POSTGRES_ISTAT_DB=istat
POSTGRES_HOST=localhost
POSTGRES_PORT=15432
POSTGRES_USER=ecosensor
POSTGRES_PASS=
POSTGRES_DB=ecosensor
POSTGRES_INITDB_ARGS="-c shared_buffers=1GB -c work_mem=50MB -c maintenance_work_mem=2GB -c autovacuum_work_mem=1GB -c wal_level=minimal -c checkpoint_completion_target=0.9 -c max_wal_senders=0 -c random_page_cost=1.0"
OPEN_METEO_MODELS=ncep_gfs013,copernicus_era5,copernicus_dem90,cams_europe
OPEN_METEO_VARIABLES=temperature_2m,precipitation,carbon_monoxide,nitrogen_dioxide,ozone,pm10,pm2_5
OPEN_METEO_MAX_AGE_DAYS=3
OPEN_METEO_REPEAT_INTERVAL=5
OPEN_METEO_CONCURRENT=4
OPEN_METEO_PORT=15434
POSTGRES_OSM_HOST=localhost
POSTGRES_OSM_PORT=15432
POSTGRES_OSM_USER=osm
POSTGRES_OSM_PASS=
POSTGRES_OSM_DB=osm
EOF

# login github docker registry
# export GITHUB_TOKEN=$(aws ssm get-parameter --name /ecosensor/ghcr-token --query Parameter.Value --output text)
export GITHUB_TOKEN=
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# start docker stack
docker compose rm -f
docker compose pull
docker compose --profile all up -d