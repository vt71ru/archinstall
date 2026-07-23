#!/usr/bin/env bash
#
# ArchInstaller
# System locale module
#

########################################
# Список локалей
########################################

LOCALES=()

########################################
# Загрузка локалей
########################################

load_locales()
{
    mapfile -t LOCALES < <(
        sed -n \
        's/^#\([A-Za-z_]*\.UTF-8\).*/\1/p' \
        /etc/locale.gen
    )
}

########################################
# Выбор локали
########################################

select_locales()
{
    section "Системная локаль"

    load_locales

    menu_select \
        "Выберите локаль" \
        "${LOCALES[@]}"

    SELECTED_LOCALE="${LOCALES[$((REPLY-1))]}"

    export SELECTED_LOCALE
}

########################################
# Настройка локали
########################################

configure_locale()
{
    local root="${1:-/mnt}"

    sed -i \
        "s/^#${SELECTED_LOCALE}/${SELECTED_LOCALE}/" \
        "${root}/etc/locale.gen"

    arch-chroot "$root" locale-gen

    echo "LANG=${SELECTED_LOCALE}" \
        > "${root}/etc/locale.conf"

    msg_success "Локаль настроена"
}
