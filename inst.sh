#!/usr/bin/env bash

DISK = ""

echo -ne "
-------------------------------------------------------------------------
    _             _     _           _        _ _
   / \   _ __ ___| |__ (_)_ __  ___| |_ __ _| | | ___ _ __
  / _ \ | '__/ __| '_ \| | '_ \/ __| __/ _  | | |/ _ \ '__|
 / ___ \| | | (__| | | | | | | \__ \ || (_| | | |  __/ |
/_/   \_\_|  \___|_| |_|_|_| |_|___/\__\__,_|_|_|\___|_|
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------
"
echo -ne "
-----------------------------------------------------------------------
                    Arch Install Script 1 - Drive Setup.
-----------------------------------------------------------------------
"

lsblk
echo "Specify drive name for install (ex. /dev/sda, /dev/nvme0n1). THIS WILL FORMAT & PARTITION THE SPECIFIED DRIVE!"
read -r DISK

if [[ ! -b $DISK ]]; then
    echo "Disk $DISK does not exist."
    exit 1
fi

echo -e "\nFormatting disk...\n$HR"

# disk prep
sgdisk -Z $DISK 2>/dev/null # zap all on disk
sgdisk -a 2048 -o $DISK 2>/dev/null  # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1:0:1024M $DISK 2>/dev/null  # partition 1 (boot)
sgdisk -n 2:0:8G $DISK 2>/dev/null  # partition 2 (SWAP - change to desired size)
sgdisk -n 3:0:75G $DISK 2>/dev/null # partition 3 (root - change to desired size)
sgdisk -n 4:0:0 $DISK 2>/dev/null # partition 4 (home, remaining space)

# partition types
sgdisk -t 1:ef00 $DISK 2>/dev/null
sgdisk -t 2:8200 $DISK 2>/dev/null
sgdisk -t 3:8300 $DISK 2>/dev/null
sgdisk -t 4:8300 $DISK 2>/dev/null

# label partitions
sgdisk -c 1:"boot" $DISK 2>/dev/null
sgdisk -c 2:"swap" $DISK 2>/dev/null
sgdisk -c 3:"root" $DISK 2>/dev/null
sgdisk -c 4:"home" $DISK 2>/dev/null 

echo -e "\nCreating Filesystems...\n$HR"

mkfs.fat -F32 ${DISK}1 # FAT32 boot partition
mkswap ${DISK}2 # create SWAP
swapon ${DISK}2 # enable SWAP
mkfs.ext4 ${DISK}3
mkfs.ext4 ${DISK}4

echo "-------------------------------------------------"
echo "Mounting Partitions"
echo "-------------------------------------------------"

mount ${DISK}3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount ${DISK}1 /mnt/boot
mount ${DISK}4 /mnt/home

sleep 100

echo "-------------------------------------------------"
echo "Downloading 2nd install script"
echo "-------------------------------------------------"

echo 'Choice mirror for setup'
echo "Create backup fo mirror list"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlis.orig

pacman -S reflector
reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

echo -ne "
-----------------------------------------------------------------------
                    Installing to drive
-----------------------------------------------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware vim dhcpcd netctl sbctl --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab

echo -ne "
-------------------------------------------------------------------------
                    Configuring the system
-------------------------------------------------------------------------
"

genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh
