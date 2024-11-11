#!/bin/bash

###############################
#
# Parametros:
#  - Lista de Usuarios a crear
#  - Usuario del cual se obtendra la clave
#
#  Tareas:
#  - Crear los usuarios segun la lista recibida en los grupos descriptos
#  - Los usuarios deberan de tener la misma clave que la del usuario pasado por parametro
#
###############################

LISTA=$1
USUARIO_DE_LA_CLAVE=$2

ANT_IFS=$IFS
IFS=$'\n'
for LINEA in `cat $LISTA |  grep -v ^#`
do
	USUARIO=$(echo  $LINEA |awk -F ',' '{print $1}')
	GRUPO_PRIMARIO=$(echo  $LINEA |awk -F ',' '{print $2}')
	GRUPO_SECUNDARIO=$(echo  $LINEA |awk -F ',' '{print $3}')

	# Creo los grupos primarios pasados por la lista.
	sudo groupadd $GRUPO_PRIMARIO
	
	# Creo el grupo secundario de los usuarios. Como es el mismo para
	# todos, lo paso por un if asi no me da error en cada vuelta del for.

	if grep -q $GRUPO_SECUNDARIO /etc/group; then
		echo "Este grupo ya fue creado..."
	else
		sudo groupadd $GRUPO_SECUNDARIO
	fi

	sudo useradd -m -s /bin/bash -g $GRUPO_PRIMARIO -G $GRUPO_SECUNDARIO -p $(sudo grep $USUARIO_DE_LA_CLAVE /etc/shadow |awk -F ':' '{print $2}') $USUARIO
done
IFS=$ANT_IFS

