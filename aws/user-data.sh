#!/bin/bash

# pull ecosensor code
# Check if the ecosensor directory exists
if [ ! -d "~/ecosensor" ]; then
    echo "Directory ecosensor does not exist. Cloning repository..."
    git clone https://github.com/EMP-Projects/EcoSensor ~/ecosensor

    # TODO: authorize github artifact
    

else
    echo "Directory ecosensor exists. Pulling latest changes..."
    cd ~/ecosensor
    git pull
fi

cd ~/ecosensor
dotnet build
dotnet run