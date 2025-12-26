#!/usr/bin/env bash
# Main script for the installation

echo -e "Begin........"

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
