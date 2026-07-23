#!/usr/bin/env bash
#
# ArchInstaller
# Partition management module
#

########################################
# Partition variables
########################################

PARTITION_METHOD="${PARTITION_METHOD:-}"

EFI_PARTITION="${EFI_PARTITION:-}"
ROOT_PARTITION="${ROOT_PARTITION:-}"
SWAP_PARTITION="${SWAP_PARTITION:-}"

########################################
# Partition method selection
########################################

select_partition_method()
{
    local choice

    section "Метод разметки диска"

    [[ -n "${TARGET_DISK:-}" ]] \
        || die "Диск не выбран"

    if [[ -z "${BOOT_MODE:-}" ]]; then
        detect_boot_mode
    fi

    echo
    echo "Текущая конфигурация:"
    echo
    echo "Диск: $TARGET_DISK"
    echo "Режим загрузки: $BOOT_MODE"

    echo
    echo "Доступные методы:"
    echo

    echo "1) Автоматическая разметка"
    echo "2) Ручная разметка"
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
}

########################################
# Partition table creation
########################################

create_partition_table()
{
    case "$BOOT_MODE" in
        uefi)
            create_gpt_table
            ;;

        bios)
            create_mbr_table
            ;;

        *)
            die "Неизвестный режим загрузки: $BOOT_MODE"
            ;;
    esac
}

########################################
# GPT partition table
########################################

create_gpt_table()
{
    msg_info "Создание GPT таблицы: $TARGET_DISK"

    wipefs -a "$TARGET_DISK"

    parted \
        --script \
        "$TARGET_DISK" \
        mklabel gpt

    partprobe "$TARGET_DISK"

    msg_success "GPT таблица создана"
}

########################################
# MBR partition table
########################################

create_mbr_table()
{
    msg_info "Создание MBR таблицы: $TARGET_DISK"

    wipefs -a "$TARGET_DISK"

    parted \
        --script \
        "$TARGET_DISK" \
        mklabel msdos

    partprobe "$TARGET_DISK"

    msg_success "MBR таблица создана"
}

########################################
# Automatic partitioning
########################################

create_auto_partition()
{
    case "$BOOT_MODE" in
        uefi)
            create_uefi_partitions
            ;;

        bios)
            create_bios_partitions
            ;;

        *)
            die "Неизвестный режим загрузки"
            ;;
    esac
}

########################################
# UEFI partition layout
########################################

create_uefi_partitions()
{
    msg_info "Создание UEFI разделов"

    parted \
        --script \
        "$TARGET_DISK" \
        mkpart EFI fat32 1MiB 513MiB \
        set 1 esp on \
        mkpart ROOT ext4 513MiB 100%

    partprobe "$TARGET_DISK"

    EFI_PARTITION="${TARGET_DISK}1"
    ROOT_PARTITION="${TARGET_DISK}2"

    export EFI_PARTITION
    export ROOT_PARTITION

    msg_success "UEFI разделы созданы"
}

########################################
# BIOS partition layout
########################################

create_bios_partitions()
{
    msg_info "Создание BIOS разделов"

    parted \
        --script \
        "$TARGET_DISK" \
        mkpart primary ext4 1MiB 100%

    partprobe "$TARGET_DISK"

    ROOT_PARTITION="${TARGET_DISK}1"

    export ROOT_PARTITION

    msg_success "BIOS разделы созданы"
}

########################################
# Existing partitions
########################################

use_existing_partitions()
{
    local root
    local efi

    section "Использование существующих разделов"

    lsblk "$TARGET_DISK"

    echo

    read -rp "Root раздел: " root

    [[ -b "$root" ]] \
        || die "Раздел не найден: $root"

    ROOT_PARTITION="$root"

    if [[ "$BOOT_MODE" == "uefi" ]]; then

        read -rp "EFI раздел: " efi

        [[ -b "$efi" ]] \
            || die "EFI раздел не найден: $efi"

        EFI_PARTITION="$efi"

        export EFI_PARTITION
    fi

    export ROOT_PARTITION

    msg_success "Разделы выбраны"
}

########################################
# Manual partitioning
########################################

run_manual_partition()
{
    section "Ручная разметка"

    case "$BOOT_MODE" in
        uefi|bios)
            cfdisk "$TARGET_DISK"
            ;;

        *)
            die "Неизвестный режим загрузки"
            ;;
    esac

    partprobe "$TARGET_DISK"

    msg_success "Ручная разметка завершена"
}

########################################
# Partition workflow
########################################

prepare_partitions()
{
    section "Подготовка разделов"

    [[ -n "${PARTITION_METHOD:-}" ]] \
        || die "Метод разметки не выбран"

    case "$PARTITION_METHOD" in
        auto)
            create_partition_table
            create_auto_partition
            ;;

        manual)
            run_manual_partition
            ;;

        existing)
            use_existing_partitions
            ;;

        *)
            die "Неизвестный метод разметки"
            ;;
    esac

    lsblk "$TARGET_DISK"
}
