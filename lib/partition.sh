#!/usr/bin/env bash
#
# ArchInstaller
# Partition management module
#

########################################
# Partition method selection
########################################

select_partition_method()
{
    local choice

    section "Метод разметки диска"

    [[ -n "${TARGET_DISK:-}" ]] \
        || die "Диск не выбран"

    echo
    echo "Выбранный диск:"
    lsblk "$TARGET_DISK"

    echo

    echo "Доступные варианты:"
    echo

    echo "1) Автоматическая разметка"
    echo "   - EFI System Partition"
    echo "   - Linux root partition"
    echo "   - Swap (опционально)"

    echo

    echo "2) Ручная разметка"
    echo "   - fdisk"
    echo "   - cfdisk"

    echo

    echo "3) Использовать существующие разделы"

    echo

    read -rp "Выберите метод [1-3]: " choice

    case "$choice" in

        1)
            export PARTITION_METHOD="auto"
            msg_success "Выбрана автоматическая разметка"
            ;;

        2)
            export PARTITION_METHOD="manual"
            msg_success "Выбрана ручная разметка"
            ;;

        3)
            export PARTITION_METHOD="existing"
            msg_success "Использование существующих разделов"
            ;;

        *)
            die "Неизвестный вариант: $choice"
            ;;

    esac

    echo

    msg_success "Метод разметки: $PARTITION_METHOD"
}
