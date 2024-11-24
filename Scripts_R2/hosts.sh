#!/bin/bash


HOST1=$( sudo grep -i '192.168.56.4 VM1-GRUPO-ANTARTIDA' /etc/hosts)
HOST2=$( sudo grep -i '192.168.56.5 VM2-GRUPO-ANTARTIDA' /etc/hosts)



# Edicion del archivo /etc/hosts 
if [ "$HOST1" = "" -a "$HOST2" = "" ];then
	echo "192.168.56.5 VM2-GRUPO-ANTARTIDA"  | sudo tee -a /etc/hosts
	echo "192.168.56.4 VM1-GRUPO-ANTARTIDA"  | sudo tee -a /etc/hosts
	echo "Se añadieron los hosts correctamente..."
	sudo cat /etc/hosts
else
	echo "Los hosts que esta queriendo agregar ya estan en el archivo /etc/hosts"
fi

# Cruzar la claves
if [ -f ~/.ssh/id_ed25519.pub ];then
	echo "La clave publica ya existe"
else
	echo "Generando par de claves"
	ssh-keygen -t ed25519
fi

CLAVES_AUTORIZADAS_DEL_OTRO_EQUIPO=$( ssh -o StrictHostKeyChecking=no vagrant@VM2-GRUPO-ANTARTIDA "cat ~/.ssh/authorized_keys" )
#echo "$CLAVES_AUTORIZADAS_DEL_OTRO_EQUIPO"
CLAVE_LOCAL=$(cat ~/.ssh/id_ed25519.pub)



VERIFICACION=$( echo "$CLAVES_AUTORIZADAS_DEL_OTRO_EQUIPO" | grep "$CLAVE_LOCAL" )

if [ "$VERIFICACION" == "" ];then
	sshpass "vagrant" ssh-copy-id -o StrictHostKeyChecking=no vagrant@VM2-GRUPO-ANTARTIDA
else
	echo "La clave ya se cruzó..."
fi


