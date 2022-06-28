set_tz() {
  ZONE=$(dialog --nocancel --ok-button "ok" --menu "zone" 18 60 11 $zonelist 3>&1 1>&2 2>&3)
}
