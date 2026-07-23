#!/usr/bin/env bash
#
# ArchInstaller
# Cleanup module
#

########################################
# Очистка временных ресурсов
########################################

cleanup_mounts()
{
    local mounts=(
        /mnt/boot
        /mnt
    )

    local mount

    for mount in "${mounts[@]}"; do
        if mountpoint -q "$mount" 2>/dev/null; then
            umount -R "$mount"
            msg_info "Размонтировано: $mount"
        fi
    done
}

########################################
# Очистка при ошибке
########################################

cleanup_error()
{
    local code="$1"
    local command="$2"

    msg_error "Ошибка выполнения"
    msg_error "Код: $code"
    msg_error "Команда: $command"

    cleanup_mounts
}

########################################
# Очистка после завершения
########################################

cleanup_finish()
{
    msg_info "Очистка завершена"

    cleanup_mounts
}

########################################
# Основная функция очистки
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
