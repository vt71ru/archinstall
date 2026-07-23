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
# Early error handling
########################################

die()
{
    echo

    if declare -f msg_error >/dev/null; then
        msg_error "$*"
    else
        echo "[ERROR] $*" >&2
    fi

    exit 1
}

########################################
# Required modules
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
# Required commands
########################################

readonly COMMANDS=(
    bash
    awk
    sed
    grep
    lsblk
    ip
    mount
    umount
    blkid
)

########################################
# Environment checks
########################################

check_root()
{
    [[ "$EUID" -eq 0 ]] \
        || die "Установщик должен быть запущен от root"
}

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
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
}

########################################
# Module loading
########################################

load_modules()
{
    local module
    local file

    echo
    echo "=== Загрузка модулей ==="

    for module in "${MODULES[@]}"; do

        file="${LIB_DIR}/${module}.sh"

        [[ -r "$file" ]] \
            || die "Модуль недоступен: $file"

        # shellcheck disable=SC1090
        source "$file"

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
# Function validation
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
# Signal handling
########################################

install_traps()
{
    if declare -f cleanup >/dev/null; then

        trap '
            code=$?
            cleanup "$code" "$BASH_COMMAND"
            exit "$code"
        ' ERR

        trap '
            cleanup 130 "Interrupted"
            exit 130
        ' SIGINT

        trap '
            cleanup 143 "Terminated"
            exit 143
        ' SIGTERM

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

    check_root

    check_project

    load_config

    load_modules

    check_commands

    check_functions

    install_traps
}

########################################
# Installation workflow
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
