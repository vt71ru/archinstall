#!/usr/bin/env bash
#
# ArchInstaller
# Network module
#

########################################
# Настройки
########################################

NETWORK_TEST_HOST="${NETWORK_TEST_HOST:-archlinux.org}"
NETWORK_TIMEOUT="${NETWORK_TIMEOUT:-5}"

########################################
# Проверка IP
########################################

network_has_ip()
{
    ip -4 addr show scope global | grep -q "inet "
}

########################################
# Проверка интернета
########################################

network_test()
{
    ping -c 1 -W "$NETWORK_TIMEOUT" "$NETWORK_TEST_HOST" \
        >/dev/null 2>&1
}

########################################
# Ethernet
########################################

network_configure_ethernet()
{
    echo
    echo "[СЕТЬ] Настройка проводного соединения"

    local interface

    interface=$(ip link \
        | awk -F': ' '/^[0-9]+: / {print $2}' \
        | grep -v lo \
        | head -n1)

    if [[ -z "$interface" ]]; then
        echo "[СЕТЬ] Ethernet интерфейс не найден"
        return 1
    fi


    echo "[СЕТЬ] Интерфейс: $interface"

    ip link set "$interface" up

    if command -v dhcpcd >/dev/null 2>&1; then
        dhcpcd "$interface"
    elif command -v dhclient >/dev/null 2>&1; then
        dhclient "$interface"
    else
        echo "[СЕТЬ] DHCP клиент отсутствует"
        return 1
    fi
}

########################################
# Wi-Fi через iwctl
########################################

network_configure_wifi()
{
    echo
    echo "[СЕТЬ] Настройка Wi-Fi"

    if ! command -v iwctl >/dev/null 2>&1; then
        echo "[СЕТЬ] iwctl не найден"
        return 1
    fi


    local device
    local network

    device=$(iwctl device list \
        | awk '/station/ {print $2; exit}')


    if [[ -z "$device" ]]; then
        echo "[СЕТЬ] Wi-Fi адаптер не найден"
        return 1
    fi


    echo "[СЕТЬ] Адаптер: $device"


    iwctl station "$device" scan


    sleep 2


    echo
    echo "Доступные сети:"
    iwctl station "$device" get-networks


    echo
    read -rp "Имя Wi-Fi сети: " network


    iwctl station "$device" connect "$network"


    echo
    echo "[СЕТЬ] Ожидание подключения..."

    sleep 5
}

########################################
# Меню настройки сети
########################################

network_menu()
{
    while true; do

        echo
        echo "============================"
        echo " Настройка сети"
        echo "============================"
        echo
        echo "1) Проводное соединение"
        echo "2) Wi-Fi"
        echo "3) Повторить проверку"
        echo


        read -rp "Выбор: " choice


        case "$choice" in

            1)
                network_configure_ethernet
                ;;

            2)
                network_configure_wifi
                ;;

            3)
                return 0
                ;;

            *)
                echo "Неверный выбор"
                ;;
        esac

        if network_has_ip && network_test; then
            echo
            echo "[СЕТЬ] Интернет работает"
            return 0
        fi

        echo
        echo "[СЕТЬ] Подключение не удалось"
    done
}

########################################
# Главная проверка сети
########################################

check_network()
{
    echo "[СЕТЬ] Проверка подключения"

    if network_has_ip && network_test; then
        echo "[СЕТЬ] Соединение активно"
        return 0
    fi

    echo
    echo "[СЕТЬ] Интернет недоступен"

    network_menu
}
