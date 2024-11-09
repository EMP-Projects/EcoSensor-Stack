#!/bin/bash

# -----------------------------------
# L'installazione con APT può essere eseguita con pochi comandi. Prima di installare .NET, 
# eseguire i comandi seguenti per aggiungere la chiave di firma dei pacchetti Microsoft 
# all'elenco di chiavi attendibili e aggiungere il repository dei pacchetti.
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install the .NET SDK
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0