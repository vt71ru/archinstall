#!/usr/bin/env  bash

HEADER="Archlinux Installer"
EXIT_MSG="You have left from Archlinux Installer!" 

title_part="Partition the disks"

part1="Before you install Archlinux, you need to partition your hard disk.\n\n[ESC] to exit installer"
part2="Hey! Your boot mode is UEFI, so you must create an ESP partition \
(EFI system partition). If, \n\n(1)You have installed Windows on your computer, and its boot \
mode is also UEFI, if so, you will see a partition of about 200MiB later. You should not delete \
it or format it, you will use it as your ESP.\n\n(2)You don't have an ESP partition on your computer.\
You need to create an ESP partition of about 200MiB.
\n\nRember, you must ensure that there are one \
and just only one ESP on your disks.\n\n[ESC] to exit the installer"
part3="Hey! Your boot mode is Bios. In order to ensure everything goes well, I think you should ensure your disk is MBR(dos) partition structures\n\n\n[ESC] to exit the installer."
part4="Please select the disk you want to partition. Select nothing to skip.	[ESC] to exit the installer\n\nPlease confirm before typing the [ENTER], because you can't undo it"

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

part() {
dialog --no-cancel --ascii-lines --title "$title_part" --backtitle "$HEADER" --msgbox "$part1" 9 45

retval=$?
echo

case $retval in
    # 0) Yes -- partition the disks
        0)
        # if the boot mode is uefi,we should create a efi system partition
        if [ "$BOOT_MODE" = "UEFI" ]
        then
            #window
            dialog --ok-button "I Know" --ascii-lines --title "$title_part" --backtitle "$HEADER" --msgbox "$part2" 18 70

            retval=$?
            case $retval in
                255) #ESC,exit
                    echo 
                    echo $EXIT_MSG
                    exit 255
                    ;;
            esac
        else
            #window
            dialog --ok-button "I Know" --ascii-lines --title "$title_part" --backtitle "$HEADER" --msgbox "$part3" 18 70

            retval=$?
            case $retval in
                255) #ESC,exit
                    echo 
                    echo $EXIT_MSG
                    exit 255
                    ;;
            esac
        fi
        
 disk_list="$(fdisk -l | grep "Disk /dev/" | cut -d "," -f 1)"
        disk_list="${disk_list//Disk /}" # remove Disk
        disk_list="${disk_list// /}"
        disk_list="${disk_list//:/ }"
        disk_list=$(echo $disk_list | xargs)

        ## default to OFF
        count=0
        judge=0
        temp=
        for disk in $disk_list
        do
            count=$[ $count + 1 ]
            judge=$[ $count % 2 ]

            if [ "$judge" = "0" ]
            then
                # set /dev/sda default to ON
                if [ "$disk_temp" = "/dev/sda" ]
                then
                    temp="$temp $disk ON" 
                elif [[ "$disk_temp" = /dev/loop* ]] 
                then
                    continue # ignore /dev/loop*
                else
                    temp="$temp $disk OFF" 
                fi
            else
                if [[ "$disk" = /dev/loop* ]]
                then
                    disk_temp=$disk # ignore /dev/loop*
                else
                    temp="$temp $disk"
                    disk_temp=$disk
                fi
            fi
        done
        disk_list=$temp
        temp=

        dialog --no-cancel --ascii-lines --title "$title" --backtitle "$HEADER" --checklist "$part4" 18 65 18 $disk_list 2>tempfile

        retval=$?
        choice=$(cat tempfile)

        # if ESC,exit
        case $retval in 
            255) # ESC
                echo
                echo $EXIT_MSG
                exit 255;;
        esac
        
                # use cfdisk to partition disks
        for disk in $choice
        do
            cfdisk $disk
        done

        # info disk table change
        partprobe

        ;;

    ## 255) ESE -- exit the installer
        255)
        echo $EXIT_MSG
        exit 255;;
esac
}

init
part
