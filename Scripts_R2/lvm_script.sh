#!/bin/bash

echo "Haciendo partición de tipo LVM del disco de 5GB"

DISCO=$(sudo fdisk -l | grep "5 GiB" | awk '{print $2}' | awk -F ':' '{print $1}')

sudo fdisk $DISCO << LVM
n
p



t
8e
w
LVM

#Creando vg y lv no swap
wipefs -a /dev/sdc1
sudo pvcreate /dev/sdc1


sudo vgcreate vg_datos /dev/sdc1

sudo lvcreate -L +10M vg_datos -n lv_docker
sudo lvcreate -L +2.5GB vg_datos -n lv_workareas

mkfs.ext4 /dev/vg_datos/lv_docker
mkfs.ext4 /dev/vg_datos/lv_workareas

sudo mount /dev/vg_datos/lv_docker /var/lib/docker/

sudo mkdir /work/
sudo mount /dev/vg_datos/lv_workareas /work/


#Creando vg y lv swap
DISCO_2=$(sudo fdisk -l | grep "3 GiB" | awk '{print $2}' | awk -F ':' '{print $1}')

sudo fdisk $DISCO_2 << LVM
n
p



t
82
w
LVM


sudo pvcreate /dev/sdd1
sudo vgcreate vg_temp /dev/sdd1
sudo lvcreate -L 2.5GB vg_temp -n lv_swap

#Montando memoria swap

sudo mkswap /dev/vg_temp/lv_swap
sudo swapon /dev/vg_temp/lv_swap
swapon --show

#Creando particion swap de 1GB


DISCO_3=$(sudo fdisk -l | grep "2 GiB" | awk '{print $2}' | awk -F ':' '{print $1}')

sudo fdisk $DISCO_3 << memoria_swap
n
p


+1G
t
82
w
memoria_swap

sudo mkswap /dev/sde1
sudo swapon /dev/sde1
swapon --show
