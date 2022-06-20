#!/usr/bin/env bash 
language() {

    //echo "$(date -u "+%F %H:%M") : Start anarchy installer" > "${log}"
    //op_title=" -| Language Select |- "
    ILANG=$(dialog --nocancel --menu "\nAnarchy Installer\n\n \Z2*\Zn Select your install language:" 20 60 10 \
        "English" "-" \
        "Bulgarian" "Български" \
        "Dutch" "Nederlands" \
        "French" "Français" \
        "German" "Deutsch" \
        "Greek" "Greek" \
        "Hungarian" "Magyar" \
        "Indonesian" "bahasa Indonesia" \
        "Italian" "Italiano" \
        "Latvian" "Latviešu" \
        "Lithuanian" "Lietuvių" \
        "Polish" "Polski" \
        "Portuguese" "Português" \
        "Portuguese-Brazilian" "Português do Brasil" \
        "Romanian" "Română" \
        "Russian" "Russian" \
        "Spanish" "Español" \
        "Swedish" "Svenska" 3>&1 1>&2 2>&3)

    case "$ILANG" in
        "English") export lang_file="${directory}"/lang/english.lng ;;
        "Bulgarian") export lang_file="${directory}"/lang/bulgarian.lng lib=bg bro=bg ;;
        "Dutch") export lang_file="${directory}"/lang/dutch.lng lib=nl bro=nl ;;
        "French") export lang_file="${directory}"/lang/french.lng lib=fr bro=fr ;;
        "German") export lang_file="${directory}"/lang/german.lng lib=de bro=de ;;
        "Greek") export lang_file="${directory}"/lang/greek.lng lib=el bro=el ;;
        "Hungarian") export lang_file="${directory}"/lang/hungarian.lng lib=hu bro=hu ;;
        "Indonesian") export lang_file="${anarchy_directory}"/lang/indonesia.conf lib=id bro=id ;;
        "Italian") export lang_file="${directory}"/lang/italian.conf lib=it bro=it ;;
        "Latvian") export lang_file="${directory}"/lang/latvian.conf lib=lv bro=lv ;;
        "Lithuanian") export lang_file="$directory}"/lang/lithuanian.conf lib=lt bro=lt ;;
        "Polish") export lang_file="${directory}"/lang/polish.conf lib=pl bro=pl ;;
        "Portuguese") export lang_file="${directory}"/lang/portuguese.conf lib=pt bro=pt-pt ;;
        "Portuguese-Brazilian") export lang_file="${directory}"/lang/portuguese-br.conf lib=pt-br bro=pt-br ;;
        "Romanian") export lang_file="${directory}"/lang/romanian.lng lib=ro bro=ro ;;
        "Russian") export lang_file="${directory}"/lang/russian.lng lib=ru bro=ru ;;
        "Spanish") export lang_file="${directory}"/lang/spanish.lng lib=es bro=es-es ;;
        "Swedish") export lang_file="${directory}"/lang/swedish.lng lib=sv bro=sv-se ;;
    esac

}
