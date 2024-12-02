#!/bin/bash

echo "Haciendo partición de tipo LVM del disco de 5GB"


sudo fdisk /dev/sdb << LVM
n
p



t
8e
w
LVM

#Creando vg y lv no swap
sudo wipefs -a /dev/sdb1
sudo pvcreate /dev/sdb1


sudo vgcreate vg_datos /dev/sdb1

sudo lvcreate -L +10M vg_datos -n lv_docker
sudo lvcreate -L +2.5GB vg_datos -n lv_workareas

sudo mkfs.ext4 /dev/vg_datos/lv_docker
sudo mkfs.ext4 /dev/vg_datos/lv_workareas

sudo mount /dev/vg_datos/lv_docker /var/lib/docker/

sudo mkdir /work/
sudo mount /dev/vg_datos/lv_workareas /work/


#Creando vg y lv swap

sudo fdisk /dev/sdc << LVM
n
p



t
8e
w
LVM


sudo pvcreate /dev/sdc1
sudo vgcreate vg_temp /dev/sdc1
sudo lvcreate -L 2.5GB vg_temp -n lv_swap

#Montando memoria swap

sudo mkswap /dev/vg_temp/lv_swap
sudo swapon /dev/vg_temp/lv_swap
swapon --show

#Creando particion swap de 1GB



sudo fdisk /dev/sdd << memoria_swap
n
p


+1G
t
82
w
memoria_swap

sudo mkswap /dev/sdd1
sudo swapon /dev/sdd1
swapon --show


sudo systemctl restart docker
sudo systemctl status docker
