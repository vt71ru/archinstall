#!/usr/bin/env bash
#
# ArchInstaller
# Disk management module
#

########################################
# Disk helpers
########################################

get_disk_free_space()
{
    local disk="$1"
    local free="-"

    while read -r mountpoint; do
        [[ -n "$mountpoint" ]] || continue

        local value

        value=$(df -h "$mountpoint" 2>/dev/null \
            | awk 'NR==2 {print $4}')

        [[ -n "$value" ]] \
            && free="$value"

    done < <(
        lsblk \
            -nr \
            -o NAME,MOUNTPOINT \
            "$disk" \
            | awk '$2!="" {print $2}'
    )

    echo "$free"
}

get_disk_info()
{
    lsblk \
        -dn \
        -o NAME,MODEL,TYPE,SIZE,PHY-SEC \
        | awk '$3=="disk"'
}

show_disk_table()
{
    local index=1

    printf "\n"
    printf "%-4s %-28s %-18s %-10s %-12s %-15s %-15s\n" \
        "№" \
        "Модель" \
        "Путь" \
        "Тип" \
        "Размер" \
        "Свободно" \
        "Сектор"

    printf "%-4s %-28s %-18s %-10s %-12s %-15s %-15s\n" \
        "---" \
        "----------------------------" \
        "------------------" \
        "----------" \
        "------------" \
        "---------------" \
        "---------------"

    while read -r name model type size sector; do

        local path="/dev/${name}"
        local free

        free=$(get_disk_free_space "$path")

        [[ -n "$model" ]] \
            || model="Unknown"

        printf "%-4s %-28s %-18s %-10s %-12s %-15s %-15s\n" \
            "$index" \
            "${model:0:27}" \
            "$path" \
            "$type" \
            "$size" \
            "$free" \
            "$sector"

        index=$((index + 1))

    done < <(get_disk_info)

    echo
}

get_disk_by_number()
{
    local number="$1"

    lsblk \
        -dn \
        -o NAME,TYPE \
        | awk '$2=="disk" {print "/dev/"$1}' \
        | sed -n "${number}p"
}

check_disk_is_system()
{
    local disk="$1"
    local root_disk

    root_disk=$(findmnt -no SOURCE / \
        | sed -E 's/[0-9]+$//' \
        | sed -E 's/p[0-9]+$//')

    if [[ "$disk" == "$root_disk" ]]; then
        die "Нельзя выбрать текущий системный диск: $disk"
    fi
}

########################################
# Disk selection
########################################

select_disk()
{
    local choice
    local disk

    section "Выбор диска"

    [[ -n "${TARGET_DISK:-}" ]] || true

    show_disk_table

    read -rp "Введите номер диска: " choice

    disk=$(get_disk_by_number "$choice")

    [[ -n "$disk" ]] \
        || die "Диск не выбран"

    [[ -b "$disk" ]] \
        || die "Устройство отсутствует: $disk"

    check_disk_is_system "$disk"

    echo
    echo "Выбран диск:"
    lsblk "$disk"

    echo

    read -rp \
        "ВНИМАНИЕ! Все данные на $disk будут удалены. Продолжить? [yes/no]: " confirm

    [[ "$confirm" == "yes" ]] \
        || die "Операция отменена"

    export TARGET_DISK="$disk"

    msg_success "Выбран диск: $TARGET_DISK"
}
