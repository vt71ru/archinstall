#!/usr/bin/env bash
# Main script for the installation

echo -e "Begin........"
################
## CONFIGURE THESE VARIABLES
################

# Drive to install to.
DRIVE=''

# Hostname of the installed machine.
HOSTNAME=''

# Partitions
BOOTPART=''
ROOTPART=''
HOMEPART=''
SWAP=''

# System timezone.
TIMEZONE=''
# Root password (leave blank to be prompted).
ROOT_PASSWORD=''

# Main user to create (by default, added to wheel group, and others).
USER_NAME='voffka'

# The main user's password (leave blank to be prompted).
USER_PASSWORD=''

lsblk

echo -e "create partition..."

echo -e "Mount partition...."

#############
# Install base packages
#############
pacman -Sy

echo "installing base package with linux-lts"
pacstrap /mnt base linux-lts linux-lts-headers linux-firmware

#echo "installing base package with latest linux"
#pacstrap /mnt base

echo "installing other packages"
pacstrap /mnt base-devel parted gptfdisk iproute2 bind-tools networkmanager lvm2 gvfs nano fuseiso


#############
# fstab
#############
echo "fstab"
genfstab -U -p /mnt >> /mnt/etc/fstab

# Important: Manually check and edit fstab if necessary
vim /mnt/etc/fstab
