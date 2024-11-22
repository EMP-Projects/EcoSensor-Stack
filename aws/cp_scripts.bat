@echo off
setlocal

REM Controlla se è stato passato un parametro per SOURCE_FILE
if "%~1"=="" (
    echo Usage: %0 source_file host key user
    exit /b 1
)

if "%~2"=="" (
    echo Usage: %0 source_file host key user
    exit /b 1
)

if "%~3"=="" (
    echo Usage: %0 source_file host key user
    exit /b 1
)

if "%~4"=="" (
    echo Usage: %0 source_file host key user
    exit /b 1
)

set "SOURCE_FILE=%~1"
set "HOST=%~2"
set "PEM_FILE=%~3"

set "PEM_PATH=C:\Users\gzile\OneDrive\keys\%PEM_FILE%.pem"

REM Configura le variabili
set "USER=%~4"
set "DESTINATION_PATH=/home/%USER%/"

REM Copia il file utilizzando scp
scp -i "%PEM_PATH%" "%SOURCE_FILE%" "%USER%@%HOST%:%DESTINATION_PATH%"

endlocal

