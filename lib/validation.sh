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
        msg_error "Установщик должен быть запущен от root"
        return 1
    fi

    msg_success "Права root подтверждены"
}

########################################
# Проверка Arch окружения
########################################

check_arch_environment()
{
    if [[ ! -f /etc/arch-release ]]; then
        msg_warning "Система не определена как Arch Linux"
        return 1
    fi

    msg_success "Arch Linux окружение обнаружено"
}

########################################
# Проверка виртуальных файловых систем
########################################

check_system_mounts()
{
    local mounts=(
        /proc
        /sys
        /dev
    )

    local mount

    for mount in "${mounts[@]}"; do
        if [[ ! -d "$mount" ]]; then
            msg_error "Отсутствует: $mount"
            return 1
        fi
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

    if (( memory < 512 )); then
        msg_warning "Мало оперативной памяти: ${memory} MB"
    else
        msg_success "Память: ${memory} MB"
    fi
}


########################################
# Проверка режима загрузки
########################################

check_boot_mode()
{
    if [[ -d /sys/firmware/efi ]]; then
        BOOT_MODE="UEFI"
    else
        BOOT_MODE="BIOS"
    fi

    export BOOT_MODE

    msg_info "Режим загрузки: ${BOOT_MODE}"
}


########################################
# Проверка команд установки
########################################

check_installer_tools()
{
    local tools=(
        pacstrap
        arch-chroot
        genfstab
        lsblk
        fdisk
    )

    local tool

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            msg_error "Инструмент отсутствует: $tool"
            return 1
        fi
    done

    msg_success "Инструменты установки доступны"
}

########################################
# Общая проверка окружения
########################################

validate_environment()
{
    section "Проверка окружения"

    check_root \
        || return 1

    check_arch_environment \
        || return 1

    check_system_mounts \
        || return 1

    check_memory

    check_boot_mode

    check_installer_tools \
        || return 1

    msg_success "Окружение готово к установке"
}
