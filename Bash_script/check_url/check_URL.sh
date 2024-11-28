#!/bin/bash

###############################
#
# Parametros:
#  - Lista Dominios y URL
#
#  Tareas:
#  - Se debera generar la estructura de directorio pedida con 1 solo comando con las tecnicas enseñadas en clases
#  - Generar los archivos de logs requeridos.
#
###############################
LISTA=$1

LOG_FILE="/var/log/status_url.log"

sudo mkdir -p /tmp/head-check/{Error/{cliente,servidor},ok}

ANT_IFS=$IFS
IFS=$'\n'

#---- Dentro del bucle ----#
for LINEA in `cat $LISTA |  grep -v ^#`
do
  
  URL=$(echo $LINEA| awk -F ' ' '{print $2}')
  DOMINIO=$(echo $LINEA| awk -F ' ' '{print $1}')

  # Obtener el código de estado HTTP
  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")

  # Fecha y hora actual en formato yyyymmdd_hhmmss
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")


 # Registrar en el archivo /var/log/status_url.log
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee -a  "$LOG_FILE"
	

  if [[ "$STATUS_CODE" -eq 200 ]]; then
        echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee /tmp/head-check/ok/$DOMINIO.log
  elif [[ "$STATUS_CODE" -ge 400 && "$STATUS_CODE" -le 499 ]]; then
        echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee /tmp/head-check/Error/cliente/$DOMINIO.log
  elif [[ "$STATUS_CODE" -ge 500 && "$STATUS_CODE" -le 599 ]]; then
        echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee /tmp/head-check/Error/servidor/$DOMINIO.log
  fi

  sudo tree /tmp/head-check

done


#-------------------------#

IFS=$ANT_IFS
