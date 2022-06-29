#!/usr/bin/env bash
set_tz() {

Zone=$(dialog --title "Volume mount" --menu "Select:" 0 0 0 $zonelist 3>&1 1>&2 2>&3)
echo $zone
}
