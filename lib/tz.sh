#!/usr/bin/env bash
set_tz() {

    while (true)
      do
        ZONE=$(dialog --nocancel --ok-button "ok" --menu "zone_msg0" 18 60 11 $zonelist 3>&1 1>&2 2>&3)
        if (find /usr/share/zoneinfo -maxdepth 1 -type d | sed -n -e 's!^.*/!!p' | grep "$ZONE" &> /dev/null); then
            sublist=$(find /usr/share/zoneinfo/"$ZONE" -maxdepth 1 | sed -n -e 's!^.*/!!p' | sort | sed 's/$/ -/g' | grep -v "$ZONE")
            SUBZONE=$(dialog --ok-button "ok" --cancel-button "back" --menu "zone_msg1" 18 60 11 $sublist 3>&1 1>&2 2>&3)
            if [ "$?" -eq "0" ]; then
                if (find /usr/share/zoneinfo/"$ZONE" -maxdepth 1 -type  d | sed -n -e 's!^.*/!!p' | grep "$SUBZONE" &> /dev/null); then
                    sublist=$(find /usr/share/zoneinfo/"$ZONE"/"$SUBZONE" -maxdepth 1 | sed -n -e 's!^.*/!!p' | sort | sed 's/$/ -/g' | grep -v "$SUBZONE")
                    SUB_SUBZONE=$(dialog --ok-button "ok" --cancel-button "back" --menu "$zone_msg1" 15 60 7 $sublist 3>&1 1>&2 2>&3)
                    if [ "$?" -eq "0" ]; then
                        ZONE="${ZONE}/${SUBZONE}/${SUB_SUBZONE}"
                        break
                    fi
                else
                    ZONE="${ZONE}/${SUBZONE}"
                    break
                fi
            fi
        else
            break
        fi
    done

}
