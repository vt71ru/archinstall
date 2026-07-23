#!/usr/bin/env bash
#
# ArchInstaller
# Main entry point
#

set -Eeuo pipefail

########################################
# Application information
########################################

readonly APP_NAME="ArchInstaller"
readonly APP_VERSION="1.0.0"

########################################
# Project paths
########################################

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

readonly ROOT_DIR
readonly CONFIG_FILE="${ROOT_DIR}/config.sh"
readonly LIB_DIR="${ROOT_DIR}/lib"
readonly LANG_DIR="${ROOT_DIR}/lang"

########################################
# Debug mode
########################################

DEBUG="${DEBUG:-0}"

if [[ "$DEBUG" == "1" ]]; then
    set -x
fi

########################################
# Modules
########################################

readonly MODULES=(
    colors
    ui
    utils
    validation
    cleanup
    language
    network
    locale
    disks
    partition
    installer
    bootloader
    users
)

########################################
# Commands
########################################

readonly COMMANDS=(
    bash
    awk
    sed
    grep
    lsblk
    ip
)

########################################
# Error handling
########################################

die()
{
    echo
    msg_error "$*"
    exit 1
}

########################################
# Project validation
########################################

check_project()
{
    [[ -d "$LIB_DIR" ]] \
        || die "Каталог модулей отсутствует: $LIB_DIR"

    [[ -d "$LANG_DIR" ]] \
        || die "Каталог языков отсутствует: $LANG_DIR"

    [[ -f "$CONFIG_FILE" ]] \
        || die "Файл конфигурации отсутствует: $CONFIG_FILE"
}

########################################
# Configuration
########################################

load_config()
{
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
}

########################################
# Module loading
########################################

########################################
# Module loading
########################################

load_modules()
{
    local module
    local file

    # Безопасный вывод заголовка (пока функция section не загружена)
    if declare -f section >/dev/null; then
        section "Загрузка модулей"
    else
        echo "=== Загрузка модулей ==="
    fi

    for module in "${MODULES[@]}"; do
        file="${LIB_DIR}/${module}.sh"

        # Проверяем доступность файла на чтение
        [[ -r "$file" ]] \
            || die "Модуль отсутствует или недоступен: $module ($file)"

        # shellcheck source=/dev/null
        source "$file"

        # Безопасно выводим статус (msg_success появится только после загрузки ui/colors)
        if declare -f msg_success >/dev/null; then
            msg_success "$module"
        else
            echo "  [+] $module"
        fi
    done
}

########################################
# Command validation
########################################

check_commands()
{
    local cmd

    section "Проверка команд"

    for cmd in "${COMMANDS[@]}"; do
        command -v "$cmd" >/dev/null 2>&1 \
            || die "Команда отсутствует: $cmd"

        msg_success "$cmd"
    done
}

########################################
# Required functions
########################################

check_functions()
{
    local required=(
        logo_show
        validate_environment
        check_network
        select_language
        load_language
        select_locales
        select_disk
        select_partition_method
        confirm_install
        install_system
        finish_installation
    )

    local func

    section "Проверка функций"

    for func in "${required[@]}"; do
        declare -f "$func" >/dev/null \
            || die "Функция отсутствует: $func"
    done

    msg_success "Все функции доступны"
}

########################################
# Signal handlers
########################################

install_traps()
{
    if declare -f cleanup >/dev/null; then
        trap 'cleanup $? "${BASH_COMMAND}"' ERR
        trap 'cleanup 130 "Interrupted"' SIGINT
        trap 'cleanup 143 "Terminated"' SIGTERM
    fi
}

########################################
# Bootstrap
########################################

bootstrap()
{
    echo
    echo "${APP_NAME} ${APP_VERSION}"
    echo

    check_project

    load_config

    load_modules

    check_commands

    check_functions

    install_traps
}

########################################
# Main workflow
########################################

main()
{
    bootstrap

    ui_clear

    logo_show

    select_language

    load_language

    validate_environment

    check_network

    select_locales

    select_disk

    select_partition_method

    confirm_install

    install_system

    finish_installation
}

########################################
# Entry point
########################################

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
