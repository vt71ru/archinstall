#!/usr/bin/env bash
#
# ArchInstaller
# Cleanup and Signal Handling Module
#

########################################
# Обязательные функции для каркаса
########################################

# Функция экстренной очистки при выходе или ошибках
# Принимает код возврата и команду/причину сбоя
cleanup() {
    # Сразу отключаем трапы, чтобы избежать бесконечной рекурсии при ошибках внутри самого cleanup
    trap - ERR SIGINT SIGTERM EXIT

    local exit_code="${1:-0}"
    local reason="${2:-Unknown}"

    echo
    if (( exit_code == 0 )); then
        msg_success "Процесс установки завершен успешно."
        exit 0
    fi

    # Если выход произошел по ошибке или прерыванию
    msg_error "Выполнение прервано!"
    msg_error "Причина/Команда: '${reason}'"
    msg_error "Код завершения: ${exit_code}"

    # Безопасное размонтирование дисков, если они были примонтированы в /mnt
    if mountpoint -q /mnt 2>/dev/null; then
        msg_warn "Обнаружены примонтированные разделы в /mnt. Попытка безопасного размонтирования..."
        
        # swapoff, если он был включен во время установки
        if grep -q "/mnt" /proc/swaps 2>/dev/null; then
            swapoff -a 2>/dev/null || true
        fi

        # Рекурсивное ленивое размонтирование (сначала внутренние точки, затем корень)
        umount -R /mnt 2>/dev/null || umount -l /mnt 2>/dev/null || true
        
        if ! mountpoint -q /mnt 2>/dev/null; then
            msg_success "Разделы успешно размонтированы."
        else
            msg_error "Не удалось полностью размонтировать /mnt. Рекомендуется перезагрузка."
        fi
    fi

    msg_info "Очистка завершена. Выход из программы."
    exit "$exit_code"
}
