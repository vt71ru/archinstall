#!/usr/bin/env bash
#
# ArchInstaller
# Installation module
#

########################################
# Installation confirmation
########################################

confirm_install()
{
    local answer

    section "Подтверждение установки"

    [[ -n "${TARGET_DISK:-}" ]] \
        || die "Диск не выбран"

    [[ -n "${PARTITION_METHOD:-}" ]] \
        || die "Метод разметки не выбран"

    [[ -n "${BOOT_MODE:-}" ]] \
        || die "Режим загрузки не определён"

    echo
    echo "Параметры установки:"
    echo

    printf "%-20s %s\n" \
        "Диск:" \
        "$TARGET_DISK"

    printf "%-20s %s\n" \
        "Загрузка:" \
        "$BOOT_MODE"

    printf "%-20s %s\n" \
        "Разметка:" \
        "$PARTITION_METHOD"

    printf "%-20s %s\n" \
        "Root:" \
        "${ROOT_PARTITION:-не задан}"

    printf "%-20s %s\n" \
        "EFI:" \
        "${EFI_PARTITION:-нет}"

    echo

    read -rp \
        "Начать установку? Введите YES: " answer

    [[ "$answer" == "YES" ]] \
        || die "Установка отменена"

    export INSTALL_CONFIRMED=1

    msg_success "Установка подтверждена"
}

########################################
# Format partitions
########################################

format_partitions()
{
    section "Форматирование разделов"

    [[ -n "${ROOT_PARTITION:-}" ]] \
        || die "Root раздел не определён"

    mkfs.ext4 \
        -F \
        "$ROOT_PARTITION"

    if [[ "$BOOT_MODE" == "uefi" ]]; then

        [[ -n "${EFI_PARTITION:-}" ]] \
            || die "EFI раздел не определён"

        mkfs.fat \
            -F32 \
            "$EFI_PARTITION"

    fi

    msg_success "Разделы отформатированы"
}

########################################
# Mount partitions
########################################

mount_partitions()
{
    section "Монтирование разделов"

    mkdir -p /mnt

    mount \
        "$ROOT_PARTITION" \
        /mnt

    if [[ "$BOOT_MODE" == "uefi" ]]; then

        mkdir -p /mnt/boot

        mount \
            "$EFI_PARTITION" \
            /mnt/boot

    fi

    msg_success "Разделы смонтированы"
}

########################################
# Install base system
########################################

install_base_system()
{
    section "Установка базовой системы"

    pacstrap \
        -K \
        /mnt \
        base \
        linux \
        linux-firmware \
        networkmanager \
        sudo \
        nano

    msg_success "Базовая система установлена"
}

########################################
# Generate fstab
########################################

generate_fstab()
{
    section "Создание fstab"

    genfstab \
        -U \
        /mnt \
        >> /mnt/etc/fstab

    msg_success "fstab создан"
}

########################################
# Installation workflow
########################################

install_system()
{
    section "Установка Arch Linux"

    [[ "${INSTALL_CONFIRMED:-0}" == "1" ]] \
        || die "Установка не подтверждена"

    format_partitions

    mount_partitions

    install_base_system

    generate_fstab

    msg_success "Установка базовой системы завершена"
}

########################################
# Finish installation
########################################

finish_installation()
{
    section "Завершение установки"

    if mountpoint -q /mnt; then

        msg_info "Отмонтирование файловых систем"

        sync

        umount -R /mnt \
            || msg_warning "Не все разделы удалось отмонтировать"

    fi

    echo

    msg_success "Установка завершена"

    echo
    echo "Система Arch Linux установлена."
    echo
    echo "Следующие шаги:"
    echo
    echo "1. Извлеките установочный носитель"
    echo "2. Перезагрузите компьютер"
    echo

    read -rp \
        "Перезагрузить систему сейчас? [yes/no]: " answer

    case "$answer" in

        yes|YES|y|Y)
            reboot
            ;;

        *)
            echo
            echo "Перезагрузка отменена."
            echo "Выполните reboot вручную."
            ;;

    esac
}
