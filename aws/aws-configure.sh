#!/bin/bash

sudo apt update
sudo apt install -y unzip

curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o $HOME/awscliv2.zip
unzip $HOME/awscliv2.zip
sudo $HOME/aws/install

# Configure aws 
aws configure