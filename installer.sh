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
)

########################################
# Error handling
########################################

die()
{
    echo
    echo "[ERROR] $*" >&2
    exit 1
}

########################################
# Project validation
########################################

check_project()
{
    [[ -d "$LIB_DIR" ]] \
        || die "Library directory missing: $LIB_DIR"

    [[ -d "$LANG_DIR" ]] \
        || die "Language directory missing: $LANG_DIR"

    [[ -f "$CONFIG_FILE" ]] \
        || die "Config file missing: $CONFIG_FILE"
}

########################################
# Configuration
########################################

load_config()
{
    echo "[LOAD] config"

    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
}

########################################
# Module validation
########################################

check_modules()
{
    local missing=0
    local module
    local file

    for module in "${MODULES[@]}"; do
        file="${LIB_DIR}/${module}.sh"

        if [[ ! -f "$file" ]]; then
            echo "[MISSING] $file"
            ((missing++))
            continue
        fi

        if [[ ! -r "$file" ]]; then
            echo "[UNREADABLE] $file"
            ((missing++))
        fi
    done

    (( missing == 0 )) \
        || die "Module check failed"
}
########################################
# Module loading
########################################

load_modules()
{
    local module
    local file

    for module in "${MODULES[@]}"; do
        file="${LIB_DIR}/${module}.sh"

        echo "[LOAD] ${module}"

        # shellcheck source=/dev/null
        source "$file"
    done
}

########################################
# Bash version check
########################################

check_bash()
{
    if (( BASH_VERSINFO[0] < 5 )); then
        die "Bash 5+ required"
    fi
}

########################################
# External commands check
########################################

check_commands()
{
    local cmd

    for cmd in "${COMMANDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            die "Command missing: $cmd"
        fi
    done
}

########################################
# Required functions check
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

    for func in "${required[@]}"; do
        if ! declare -f "$func" >/dev/null; then
            die "Function missing: $func"
        fi
    done
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

    check_bash

    check_project

    load_config

    check_modules

    load_modules

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
