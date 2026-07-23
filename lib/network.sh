#!/usr/bin/env bash
#
# ArchInstaller
# Network module
#

########################################
# Проверка IP
########################################

network_has_ip()
{
    ip addr show | grep -q "inet "
}

########################################
# Проверка интернета
########################################

network_test()
{
    ping -c 1 archlinux.org >/dev/null 2>&1
}

########################################
# Ethernet
########################################

network_configure_ethernet()
{
    systemctl restart systemd-networkd

    network_test
}

########################################
# Wi-Fi через iwctl
########################################

network_configure_wifi()
{
    command -v iwctl >/dev/null 2>&1 \
        || {
            msg_error "iwctl отсутствует"
            return 1
        }

    iwctl
}

########################################
# Меню сети
########################################

network_menu()
{
    menu_select \
        "Тип подключения" \
        "Проводное соединение" \
        "Wi-Fi"

    case "$REPLY" in
        1)
            network_configure_ethernet
            ;;
        2)
            network_configure_wifi
            ;;
    esac
}

########################################
# Проверка сети
########################################

check_network()
{
    section "Проверка сети"

    if network_test; then
        msg_success "Интернет доступен"
        return 0
    fi

    msg_warning "Сеть не работает"

    network_menu
}
