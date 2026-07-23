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
        "Режим загрузки:" \
        "$BOOT_MODE"

    printf "%-20s %s\n" \
        "Разметка:" \
        "$PARTITION_METHOD"

    if [[ -n "${EFI_PARTITION:-}" ]]; then
        printf "%-20s %s\n" \
            "EFI раздел:" \
            "$EFI_PARTITION"
    fi

    if [[ -n "${ROOT_PARTITION:-}" ]]; then
        printf "%-20s %s\n" \
            "Root раздел:" \
            "$ROOT_PARTITION"
    fi

    if [[ -n "${SWAP_PARTITION:-}" ]]; then
        printf "%-20s %s\n" \
            "Swap раздел:" \
            "$SWAP_PARTITION"
    fi

    echo

    echo "Будут выполнены следующие действия:"
    echo
    echo " - Форматирование разделов"
    echo " - Монтирование файловых систем"
    echo " - Установка базовой системы Arch Linux"
    echo " - Настройка загрузчика"
    echo " - Создание пользователя"

    echo

    read -rp \
        "Начать установку? Введите YES для продолжения: " answer

    if [[ "$answer" != "YES" ]]; then
        die "Установка отменена пользователем"
    fi

    export INSTALL_CONFIRMED=1

    msg_success "Установка подтверждена"
}
