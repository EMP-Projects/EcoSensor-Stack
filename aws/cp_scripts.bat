@echo off
setlocal

REM Controlla se è stato passato un parametro per SOURCE_FILE
if "%~1"=="" (
    echo Usage: %0 source_file host
    exit /b 1
)

if "%~2"=="" (
    echo Usage: %0 source_file host
    exit /b 1
)

set "SOURCE_FILE=%~1"
set "HOST=%~2"

set "PEM_FILE=C:\Users\gzile\OneDrive\keys\ecosensor-ssh.pem"

REM Configura le variabili
set "USER=admin"
set "DESTINATION_PATH=/home/admin/"

REM Copia il file utilizzando scp
scp -i "%PEM_FILE%" "%SOURCE_FILE%" "%USER%@%HOST%:%DESTINATION_PATH%"

endlocal

