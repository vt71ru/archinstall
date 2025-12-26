#!/usr/bin/env bash
# Main script for the installation

# fonts color
#Green="\\033[32m"
#Red="\\033[31m"
#GreenBG="\\033[42;37m"
#RedBG="\\033[41;37m"
#Font="\\033[0m"
#Green_font_prefix="\\033[32m"
#Green_background_prefix="\\033[42;37m"
#Font_color_suffix="\\033[0m"

#echo -e "${Green}Begin........"
################
## CONFIGURE THESE VARIABLES
################

# Drive to install to.
#DRIVE=''

# Hostname of the installed machine.
#HOSTNAME=''

# Partitions
#BOOTPART=''
#ROOTPART=''
#HOMEPART=''
#SWAP=''

# System timezone.
#TIMEZONE=''
# Root password (leave blank to be prompted).
#ROOT_PASSWORD=''

# Main user to create (by default, added to wheel group, and others).
#USER_NAME='voffka'

# The main user's password (leave blank to be prompted).
#USER_PASSWORD=''

#KEYMAP='ru'
#echo -e "Enable network time synchronization:"
#timedatectl set-ntp true

#lsblk

#echo -e "Create partition..."

#echo -e "Mount partition...."
#mkfs.ext2  $BOOTPART -L boot

#############
# Install base packages
#############
#pacman -Sy
#echo -e "Create backup for mirrorlist files"
#cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
#echo-e "Configuring Pacman Mirror for specific country"
#reflector --country Russia --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
#echo -e " Manually check and edit mirrorlist if necessary"
#echo "-e Installing base package with linux"
#pacstrap /mnt base linux linux-headers linux-firmware vim git wget yajl

#############
# fstab
#############
#echo "fstab"
#genfstab -U -p /mnt >> /mnt/etc/fstab

# Important: Manually check and edit fstab if necessary
#vim /mnt/etc/fstab

init() {
#  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#  source "$DIR"/etc/setup.conf
  clear ; 
  dialog --title "Welcome to Arch Linux Installer" \
    --ok-label "Begin Installation" --msgbox "Navigating the installer is \
easy.\nYou may select options using the ARROW keys and SPACE or \
ENTER.\nAlternate keys may also be used: '+', '-', and TAB." 7 70
}

check_connection() {
  dialog --infobox "Checking internet connection..." 3 50
  # Check if a web page is available
  if ! nc -zw1 archlinux.org 443; then
    dialog --title "Connect to the Internet" \
      --msgbox "The installer was unable to detect a working internet \
connection. The installation media supports wired network devices on \
boot. Make sure the cable is plugged in. Wireless users should use the \
'iwctl' command to connect to a wireless connection.\n\nOnce you have \
a working internet connection, retry running the installer." 10 80
    reset ; exit 1
  fi
}

set_keymap() {
  while true; do
    KEYMAP=$(dialog --title "Set the Keyboard Layout" --nocancel \
      --default-item "us" --menu "Select a keymap that corresponds to your \
keyboard layout. Choose 'other' if your keymap is not listed. If you are \
unsure, the default is 'us' (United States/QWERTY).\n\nKeymap:" 22 57 10 \
"fr" "French" \
"de" "German" \
"gr" "Greek" \
"hu" "Hungarian" \
"it" "Italian" \
"pl" "Polish" \
"ru" "Russian" \
"es" "Spanish" \
"us" "United States" \
"other" "View all available keymaps" 3>&1 1>&2 2>&3)

    if [ "$KEYMAP" = "other" ]; then
      keymaps=()
      for map in $(localectl list-keymaps); do
        keymaps+=("$map" "")
      done
      KEYMAP=$(dialog --title "Set the Keyboard Layout" --cancel-label "Back" \
        --menu "Select a keymap that corresponds to your keyboard layout. The \
default is 'us' (United States/QWERTY)." 30 60 25 \
"${keymaps[@]}" 3>&1 1>&2 2>&3)
      if [ $? -eq 0 ]; then
        break
      fi
    else
      break
    fi
  done
  dialog --infobox "Setting keymap to $KEYMAP..." 3 50
  localectl set-keymap "$KEYMAP"
  loadkeys "$KEYMAP"
}

main() {
  init
  check_connection
# set_keymap
#  set_locale
#  set_timezone
#  set_hostname
#  set_root_passwd
#  create_user
#  prepare_disk
#  update_mirrorlist
#  configure_install
#  install_base
#  configure_system
#  reboot_system
}

main
