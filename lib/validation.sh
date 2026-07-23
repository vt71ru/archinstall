#!/usr/bin/env bash
#
# ArchInstaller
# Validation module
#

########################################
# Проверка root
########################################

check_root()
{
    if [[ "$EUID" -ne 0 ]]; then
        msg_error "Запустите установщик от root"
        return 1
    fi

    msg_success "Права root подтверждены"
}

########################################
# Проверка Arch ISO
########################################

check_arch_environment()
{
    [[ -f /etc/arch-release ]] \
        || {
            msg_error "Не обнаружено Arch окружение"
            return 1
        }

    msg_success "Arch Linux окружение"
}

########################################
# Проверка системных каталогов
########################################

check_system_mounts()
{
    local dir

    for dir in /proc /sys /dev; do
        [[ -d "$dir" ]] \
            || return 1
    done

    msg_success "Системные каталоги доступны"
}

########################################
# Проверка памяти
########################################

check_memory()
{
    local memory

    memory=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)

    msg_info "Память: ${memory} MB"
}

########################################
# Определение загрузки
########################################

check_boot_mode()
{
    if [[ -d /sys/firmware/efi ]]; then
        BOOT_MODE="UEFI"
    else
        BOOT_MODE="BIOS"
    fi

    export BOOT_MODE

    msg_info "Режим загрузки: $BOOT_MODE"
}

########################################
# Проверка инструментов
########################################

check_installer_tools()
{
    local tools=(
        pacstrap
        arch-chroot
        genfstab
        lsblk
    )

    local tool

    for tool in "${tools[@]}"; do
        command -v "$tool" >/dev/null 2>&1 \
            || {
                msg_error "Нет команды: $tool"
                return 1
            }
    done

    msg_success "Инструменты установки доступны"
}

########################################
# Полная проверка
########################################

validate_environment()
{
    section "Проверка окружения"

    check_root
    check_arch_environment
    check_system_mounts
    check_memory
    check_boot_mode
    check_installer_tools

    msg_success "Окружение готово"
}
