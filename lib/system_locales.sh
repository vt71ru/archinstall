#!/usr/bin/env bash
#
# ArchInstaller
# Locale module
#

########################################
# Доступные локали
########################################

LOCALES=()

########################################
# Загрузка локалей
########################################

load_locales()
{
    local locale

    LOCALES=()

    while read -r locale; do
        LOCALES+=("$locale")
    done < <(
        sed -n \
            's/^#\([[:alnum:]_@.-]\+\.UTF-8\).*/\1/p' \
            /etc/locale.gen
    )

    if (( ${#LOCALES[@]} == 0 )); then
        msg_error "Не удалось получить список локалей"
        return 1
    fi
}

########################################
# Выбор локали
########################################

select_locales()
{
    section "Выбор локали"

    load_locales || return 1

    menu_select \
        "Выберите локаль системы" \
        "${LOCALES[@]}"

    SELECTED_LOCALE="${LOCALES[$((REPLY-1))]}"

    export SELECTED_LOCALE

    msg_success "Выбрана локаль: ${SELECTED_LOCALE}"
}

########################################
# locale.gen
########################################

configure_locale_gen()
{
    local root="${1:-/mnt}"

    msg_info "Настройка locale.gen"

    sed -i \
        "s/^#${SELECTED_LOCALE}/${SELECTED_LOCALE}/" \
        "${root}/etc/locale.gen"

    arch-chroot "$root" locale-gen

    msg_success "Локали сгенерированы"
}

########################################
# locale.conf
########################################

configure_locale_conf()
{
    local root="${1:-/mnt}"

    cat > "${root}/etc/locale.conf" <<EOF
LANG=${SELECTED_LOCALE}
EOF

    msg_success "Создан locale.conf"
}

########################################
# Настройка консоли
########################################

configure_vconsole()
{
    local root="${1:-/mnt}"

    cat > "${root}/etc/vconsole.conf" <<EOF
KEYMAP=${KEYMAP:-us}
FONT=${CONSOLE_FONT:-}
EOF

    msg_success "Настроена консоль"
}

########################################
# Полная настройка
########################################

configure_locale()
{
    local root="${1:-/mnt}"

    if [[ -z "${SELECTED_LOCALE:-}" ]]; then
        msg_error "Локаль не выбрана"
        return 1
    fi

    section "Настройка локали"

    configure_locale_gen "$root" || return 1

    configure_locale_conf "$root"

    configure_vconsole "$root"

    msg_success "Локаль успешно настроена"
}
