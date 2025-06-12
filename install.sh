#!/usr/bin/env  bash

BOOT_MODE=""

init() {
echo -e "Begin..............................."

# if `sys/firware/efi/efivars` directory exist, the 
# boot mode is UEFI. otherwise,the boot mode is BIOS
if [ -d "/sys/firmware/efi/efivars" ]
then
    BOOT_MODE="UEFI"
    echo "Boot mode is UEFI"
else
    BOOT_MODE="BIOS"
    echo "Boot mode is BIOS"
fi

}

init
