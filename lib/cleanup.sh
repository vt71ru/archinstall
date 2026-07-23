#!/usr/bin/env bash
#
# ArchInstaller
# Cleanup module
#

########################################
# Размонтирование
########################################

cleanup_mounts()
{
    local mount

    for mount in /mnt/boot /mnt; do
        if mountpoint -q "$mount" 2>/dev/null; then
            umount -R "$mount"
            msg_info "Размонтировано: $mount"
        fi
    done
}

########################################
# Ошибка
########################################

cleanup_error()
{
    local code="$1"
    local command="$2"

    msg_error "Ошибка: $command"
    msg_error "Код: $code"

    cleanup_mounts
}

########################################
# Завершение
########################################

cleanup_finish()
{
    cleanup_mounts
}

########################################
# Основная очистка
########################################

cleanup()
{
    local code="${1:-0}"
    local command="${2:-}"

    if (( code != 0 )); then
        cleanup_error "$code" "$command"
    else
        cleanup_finish
    fi
}
