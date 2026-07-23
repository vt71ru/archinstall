#!/usr/bin/env bash
#
# ArchInstaller
# Environment Validation Module
#

# Глобальные переменные состояния среды (будут доступны другим модулям)
IS_EFI=0
SYS_ARCH=""

########################################
# Обязательные функции для каркаса
########################################

# Проверяет архитектуру, режим загрузки и базовые лимиты системы
validate_environment() {
    msg_step "Проверка аппаратного окружения"

    # 1. Проверка архитектуры процессора
    SYS_ARCH="$(uname -m)"
    if [[ "$SYS_ARCH" != "x86_64" ]]; then
        die "Arch Linux официально поддерживает только архитектуру x86_64. Ваша система: $SYS_ARCH"
    fi
    msg_success "Архитектура процессора: x86_64"

    # 2. Проверка режима загрузки (UEFI или Legacy BIOS)
    if [[ -d "/sys/firmware/efi/efivars" ]]; then
        IS_EFI=1
        msg_success "Режим загрузки: UEFI (рекомендуемый)"
    else
        IS_EFI=0
        msg_warn "Режим загрузки: Legacy BIOS (устаревший)"
    fi
    export IS_EFI

    # 3. Проверка объема оперативной памяти (минимум 1 ГБ для стабильной работы pacman)
    local total_mem_kb
    total_mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    local total_mem_mb=$(( total_mem_kb / 1024 ))

    if (( total_mem_mb < 1024 )); then
        msg_warn "Обнаружено мало оперативной памяти: ${total_mem_mb}MB. Возможны сбои при сборке пакетов."
    else
        msg_success "Объем оперативной памяти: ${total_mem_mb}MB"
    fi
}
