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
# Required commands
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
# Project check
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
# Load config
########################################

load_config()
{
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
}

########################################
# Check modules
########################################

check_modules()
{
    local module
    local file

    section "Проверка модулей"

    for module in "${MODULES[@]}"; do
        file="${LIB_DIR}/${module}.sh"

        if [[ ! -f "$file" ]]; then
            msg_error "Отсутствует модуль: $module"
            return 1
        fi

        if [[ ! -r "$file" ]]; then
            msg_error "Нет доступа к модулю: $module"
            return 1
        fi

        msg_success "$module"
    done
}

########################################
# Load modules
########################################

load_modules()
{
    local module
    local file

    section "Загрузка модулей"

    for module in "${MODULES[@]}"; do
        file="${LIB_DIR}/${module}.sh"

        # shellcheck source=/dev/null
        source "$file"

        msg_success "$module"
    done
}

########################################
# Module list
########################################

modules_list()
{
    section "Активные модули"

    local module

    for module in "${MODULES[@]}"; do
        echo -e "${GREEN}[ OK ]${RESET} ${module}"
    done

    echo
}

########################################
# Bash version
########################################

check_bash()
{
    if (( BASH_VERSINFO[0] < 5 )); then
        die "Требуется Bash версии 5 или выше"
    fi
}

########################################
# Commands check
########################################

check_commands()
{
    local cmd

    section "Проверка команд"

    for cmd in "${COMMANDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            msg_error "Команда отсутствует: $cmd"
            return 1
        fi

        msg_success "$cmd"
    done
}

########################################
# Functions check
########################################

check_functions()
{
    local required=(
        logo_show
        check_root
        validate_environment
        check_network
        select_language
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
        if ! declare -f "$func" >/dev/null; then
            msg_error "Функция отсутствует: $func"
            return 1
        fi

        msg_success "$func"
    done
}

########################################
# Traps
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

    check_bash
    check_project
    load_config
    check_modules
    load_modules
    modules_list
    check_commands
    check_functions
    install_traps

    if declare -f init_logging >/dev/null; then
        init_logging
    fi
}

########################################
# Main workflow
########################################

main()
{
    bootstrap

    ui_clear

    logo_show

    check_root

    select_language

    if declare -f load_language >/dev/null; then
        load_language
    fi

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
