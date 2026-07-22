#!/usr/bin/env bash
set -euo pipefail

DISK = ""
logo_show() {
echo -ne "
-------------------------------------------------------------------------
    _             _     _           _        _ _
   / \   _ __ ___| |__ (_)_ __  ___| |_ __ _| | | ___ _ __
  / _ \ | '__/ __| '_ \| | '_ \/ __| __/ _  | | |/ _ \ '__|
 / ___ \| | | (__| | | | | | | \__ \ || (_| | | |  __/ |
/_/   \_\_|  \___|_| |_|_|_| |_|___/\__\__,_|_|_|\___|_|
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------
}

# ============================================
# Цвета для вывода
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# ============================================
# Функции вывода
# ============================================
info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
header()  { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
fail()    { echo -e "${RED}[✗]${NC} $1"; }

# ============================================
# Обработка ошибок
# ============================================
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo -e "\n${RED}${BOLD}❌ Скрипт прерван с ошибкой (код: $exit_code)${NC}"
        echo -e "${YELLOW}Выполняется очистка...${NC}"
        
        # Размонтирование если что-то смонтировано
        if mount | grep -q "/mnt"; then
            umount -R /mnt 2>/dev/null || true
            info "Диски размонтированы"
        fi
        
        # Восстановление клавиатуры
        loadkeys us 2>/dev/null || true
    fi
    exit $exit_code
}

trap cleanup ERR SIGINT SIGTERM EXIT

# ============================================
# Проверка прав root
# ============================================
check_root() {
    header "ПРОВЕРКА ПРАВ"
    if [[ $EUID -ne 0 ]]; then
        error "Этот скрипт должен запускаться с root правами!"
        error "Запустите: sudo $0"
        exit 1
    fi
    success "Права root получены"
}

# ============================================
# Выбор языка установщика
# ============================================
select_language() {
    header "ВЫБОР ЯЗЫКА УСТАНОВЩИКА"
    echo -e "${CYAN}Доступные языки:${NC}"
    echo "  1) Русский"
    echo "  2) English"
    echo ""
    
    while true; do
        read -p "$(echo -e ${YELLOW}"Введите номер (1-2): "${NC})" lang_choice
        
        case $lang_choice in
            1)
                LANG="ru"
                MSG_WELCOME="Добро пожаловать в установщик Arch Linux!"
                MSG_NET_CHECK="Проверка интернет-соединения"
                MSG_NET_OK="Интернет доступен"
                MSG_NET_FAIL="Интернет не доступен"
                MSG_NET_CONF="Настройка сети"
                MSG_NET_WIRED="Проводное соединение (DHCP)"
                MSG_NET_WIFI="Wi-Fi (iwctl)"
                MSG_DISK_SEL="Выбор диска для установки"
                MSG_AUTO="Автоматическая разметка"
                MSG_MANUAL="Ручная разметка"
                MSG_LOCALE="Настройка локалей"
                MSG_FINISH="Установка завершена!"
                break
                ;;
            2)
                LANG="en"
                MSG_WELCOME="Welcome to Arch Linux installer!"
                MSG_NET_CHECK="Checking internet connection"
                MSG_NET_OK="Internet is available"
                MSG_NET_FAIL="Internet is not available"
                MSG_NET_CONF="Network configuration"
                MSG_NET_WIRED="Wired connection (DHCP)"
                MSG_NET_WIFI="Wi-Fi (iwctl)"
                MSG_DISK_SEL="Select disk for installation"
                MSG_AUTO="Automatic partitioning"
                MSG_MANUAL="Manual partitioning"
                MSG_LOCALE="Locale configuration"
                MSG_FINISH="Installation complete!"
                break
                ;;
            *)
                error "Неверный ввод. Пожалуйста, выберите 1 или 2."
                ;;
        esac
    done
    
    echo -e "\n${GREEN}${BOLD}$MSG_WELCOME${NC}\n"
}

# ============================================
# Проверка и настройка сети
# ============================================
check_network() {
    header "$MSG_NET_CHECK"
    
    # Проверка через разные методы
    local connected=false
    
    if ping -c 3 archlinux.org &>/dev/null; then
        connected=true
    elif ping -c 3 google.com &>/dev/null; then
        connected=true
    elif curl -s --max-time 5 http://archlinux.org &>/dev/null; then
        connected=true
    fi
    
    if [[ "$connected" == true ]]; then
        success "$MSG_NET_OK"
        return 0
    fi
    
    fail "$MSG_NET_FAIL"
    
    # Предлагаем настройку сети
    header "$MSG_NET_CONF"
    echo "1) $MSG_NET_WIRED"
    echo "2) $MSG_NET_WIFI"
    echo "3) Пропустить и выйти"
    echo ""
    
    while true; do
        read -p "$(echo -e ${YELLOW}"Выберите вариант (1-3): "${NC})" net_choice
        
        case $net_choice in
            1)
                info "Запуск DHCP клиента..."
                dhcpcd &
                sleep 5
                if ping -c 2 archlinux.org &>/dev/null; then
                    success "Проводное подключение установлено"
                    return 0
                else
                    error "Не удалось получить IP по DHCP"
                fi
                ;;
            2)
                info "Запуск iwd для настройки Wi-Fi..."
                systemctl start iwd 2>/dev/null || iwctl
                echo -e "${CYAN}Используйте команды iwctl:${NC}"
                echo "  device list              - показать устройства"
                echo "  station wlan0 scan       - сканировать сети"
                echo "  station wlan0 connect SSID - подключиться"
                echo ""
                iwctl
                if [[ $? -eq 0 ]] && ping -c 2 archlinux.org &>/dev/null; then
                    success "Wi-Fi подключение установлено"
                    return 0
                fi
                ;;
            3)
                error "Без интернета установка невозможна. Выход."
                exit 1
                ;;
            *)
                error "Неверный выбор"
                ;;
        esac
    done
}

# ============================================
# Выбор локалей для установленной системы
# ============================================
select_locales() {
    header "$MSG_LOCALE"
    
    echo -e "${CYAN}Доступные локали (введите через пробел):${NC}"
    echo "  en_US.UTF-8 UTF-8     - Английская (рекомендуется)"
    echo "  ru_RU.UTF-8 UTF-8     - Русская"
    echo "  de_DE.UTF-8 UTF-8     - Немецкая"
    echo "  fr_FR.UTF-8 UTF-8     - Французская"
    echo "  es_ES.UTF-8 UTF-8     - Испанская"
    echo ""
    echo -e "${YELLOW}По умолчанию: en_US.UTF-8 ru_RU.UTF-8${NC}"
    read -p "$(echo -e ${YELLOW}"Введите локали: "${NC})" -e -i "en_US.UTF-8 ru_RU.UTF-8" locale_input
    echo ""
    
    # Разбиваем в массив
    IFS=' ' read -ra LOCALES <<< "$locale_input"
    
    # Проверяем, что хотя бы одна локаль выбрана
    if [[ ${#LOCALES[@]} -eq 0 ]]; then
        warn "Локали не выбраны, используем en_US.UTF-8"
        LOCALES=("en_US.UTF-8 UTF-8")
    fi
    
    success "Выбрано локалей: ${#LOCALES[@]}"
    for loc in "${LOCALES[@]}"; do
        echo "  • $loc"
    done
}

# ============================================
# Функция получения информации о дисках
# ============================================
get_disk_info() {
    local disk=$1
    
    # Получаем модель
    local model=$(cat "/sys/block/$(basename $disk)/device/model" 2>/dev/null || echo "Unknown")
    
    # Получаем тип (SSD/HDD)
    local rotational=$(cat "/sys/block/$(basename $disk)/queue/rotational" 2>/dev/null || echo "0")
    local disk_type
    if [[ "$rotational" == "0" ]]; then
        disk_type="SSD/NVMe"
    else
        disk_type="HDD"
    fi
    
    # Получаем размер
    local size_bytes=$(blockdev --getsize64 "$disk" 2>/dev/null || echo "0")
    local size_gb=$(awk -v bytes=$size_bytes 'BEGIN {printf "%.1f", bytes/1024/1024/1024}')
    
    echo "$model:$disk_type:${size_gb}G"
}

# ============================================
# Отображение доступных дисков
# ============================================
list_disks() {
    header "$MSG_DISK_SEL"
    
    echo -e "${CYAN}${BOLD}Доступные диски:${NC}"
    echo -e "${WHITE}┌──────┬──────────────────────────────────────┬──────────┬────────┬──────────┐${NC}"
    echo -e "${WHITE}│ ${BOLD}№${NC}    │ ${BOLD}Путь${NC}                                │ ${BOLD}Модель${NC}         │ ${BOLD}Тип${NC}    │ ${BOLD}Размер${NC}   │${NC}"
    echo -e "${WHITE}├──────┼──────────────────────────────────────┼──────────┼────────┼──────────┤${NC}"
    
    local disks=()
    local i=1
    
    # Ищем все диски
    for disk in /dev/sd[a-z] /dev/nvme[0-9]n[0-9] /dev/vd[a-z] /dev/mmcblk[0-9]; do
        if [[ -b "$disk" ]] && [[ "$(basename $disk)" != *"part"* ]] && [[ "$(basename $disk)" != *"p"*[0-9] ]]; then
            disks+=("$disk")
            local info=$(get_disk_info "$disk")
            IFS=':' read -r model disk_type size <<< "$info"
            
            printf "${WHITE}│${NC} ${YELLOW}%-4s${NC} ${WHITE}│${NC} %-36s ${WHITE}│${NC} %-14s ${WHITE}│${NC} %-6s ${WHITE}│${NC} %-8s ${WHITE}│${NC}\n" "$i." "$disk" "$model" "$disk_type" "$size"
            ((i++))
        fi
    done
    
    echo -e "${WHITE}└──────┴──────────────────────────────────────┴──────────┴────────┴──────────┘${NC}"
    echo ""
    
    # Сохраняем массив для использования
    DISK_ARRAY=("${disks[@]}")
}

# ============================================
# Выбор диска
# ============================================
select_disk() {
    list_disks
    
    if [[ ${#DISK_ARRAY[@]} -eq 0 ]]; then
        error "Диски не найдены!"
        exit 1
    fi
    
    while true; do
        read -p "$(echo -e ${YELLOW}"Выберите номер диска (1-${#DISK_ARRAY[@]}): "${NC})" disk_num
        
        if [[ "$disk_num" =~ ^[0-9]+$ ]] && (( disk_num >= 1 && disk_num <= ${#DISK_ARRAY[@]} )); then
            SELECTED_DISK="${DISK_ARRAY[$((disk_num-1))]}"
            success "Выбран диск: $SELECTED_DISK"
            
            # Предупреждение
            echo -e "\n${RED}${BOLD}⚠ ВНИМАНИЕ: Все данные на $SELECTED_DISK будут уничтожены!${NC}"
            read -p "$(echo -e ${YELLOW}"Продолжить? (y/N): "${NC})" confirm
            if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                error "Установка отменена пользователем"
                exit 0
            fi
            break
        else
            error "Неверный номер. Введите число от 1 до ${#DISK_ARRAY[@]}"
        fi
    done
}

# ============================================
# Выбор метода разметки
# ============================================
select_partition_method() {
    header "ВЫБОР МЕТОДА РАЗМЕТКИ"
    
    echo "1) $MSG_AUTO"
    echo "2) $MSG_MANUAL"
    echo ""
    
    while true; do
        read -p "$(echo -e ${YELLOW}"Выберите вариант (1-2): "${NC})" method_choice
        
        case $method_choice in
            1)
                auto_partition
                break
                ;;
            2)
                manual_partition
                break
                ;;
            *)
                error "Неверный выбор"
                ;;
        esac
    done
}

# ============================================
# Автоматическая разметка
# ============================================
auto_partition() {
    header "АВТОМАТИЧЕСКАЯ РАЗМЕТКА"
    
    # Определяем UEFI или BIOS
    if [[ -d /sys/firmware/efi ]]; then
        BOOT_MODE="UEFI"
        info "Режим загрузки: UEFI"
        
        # Создаем GPT таблицу
        parted -s "$SELECTED_DISK" mklabel gpt
        
        # EFI раздел (512MB)
        parted -s "$SELECTED_DISK" mkpart primary fat32 1MiB 512MiB
        parted -s "$SELECTED_DISK" set 1 esp on
        
        # Корневой раздел (все остальное)
        parted -s "$SELECTED_DISK" mkpart primary ext4 512MiB 100%
        
        # Определяем имена разделов
        if [[ "$SELECTED_DISK" == *"nvme"* ]] || [[ "$SELECTED_DISK" == *"mmcblk"* ]]; then
            EFI_PART="${SELECTED_DISK}p1"
            ROOT_PART="${SELECTED_DISK}p2"
        else
            EFI_PART="${SELECTED_DISK}1"
            ROOT_PART="${SELECTED_DISK}2"
        fi
        
        # Форматирование
        info "Форматирование EFI раздела..."
        mkfs.fat -F32 "$EFI_PART"
        success "EFI раздел отформатирован"
        
        info "Форматирование корневого раздела..."
        mkfs.ext4 -F "$ROOT_PART"
        success "Корневой раздел отформатирован"
        
        # Монтирование
        info "Монтирование разделов..."
        mount "$ROOT_PART" /mnt
        mkdir -p /mnt/boot
        mount "$EFI_PART" /mnt/boot
        
    else
        BOOT_MODE="BIOS"
        info "Режим загрузки: BIOS"
        
        # Создаем MBR таблицу
        parted -s "$SELECTED_DISK" mklabel msdos
        
        # Один раздел
        parted -s "$SELECTED_DISK" mkpart primary ext4 1MiB 100%
        parted -s "$SELECTED_DISK" set 1 boot on
        
        ROOT_PART="${SELECTED_DISK}1"
        
        # Форматирование
        info "Форматирование корневого раздела..."
        mkfs.ext4 -F "$ROOT_PART"
        success "Корневой раздел отформатирован"
        
        # Монтирование
        info "Монтирование раздела..."
        mount "$ROOT_PART" /mnt
    fi
    
    success "Автоматическая разметка завершена"
}

# ============================================
# Ручная разметка через fdisk
# ============================================
manual_partition() {
    header "РУЧНАЯ РАЗМЕТКА"
    
    echo -e "${YELLOW}Открывается fdisk для ручной разметки...${NC}"
    echo -e "${CYAN}Инструкция:${NC}"
    echo "  1. g - создать GPT таблицу (для UEFI)"
    echo "  2. o - создать DOS таблицу (для BIOS)"
    echo "  3. n - создать новый раздел"
    echo "  4. t - изменить тип раздела"
    echo "  5. w - записать изменения и выйти"
    echo ""
    read -p "$(echo -e ${YELLOW}"Нажмите Enter для продолжения...${NC}")"
    
    fdisk "$SELECTED_DISK"
    
    # После выхода из fdisk, предоставляем выбор разделов
    echo -e "\n${CYAN}Теперь выберите разделы для установки:${NC}"
    lsblk "$SELECTED_DISK"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Введите корневой раздел (например, ${SELECTED_DISK}2): "${NC})" ROOT_PART
    
    if [[ -d /sys/firmware/efi ]]; then
        read -p "$(echo -e ${YELLOW}"Введите EFI раздел (например, ${SELECTED_DISK}1): "${NC})" EFI_PART
        info "Форматирование EFI раздела..."
        mkfs.fat -F32 "$EFI_PART"
        mount "$EFI_PART" /mnt/boot
    fi
    
    info "Форматирование корневого раздела..."
    mkfs.ext4 -F "$ROOT_PART"
    mount "$ROOT_PART" /mnt
    
    success "Ручная разметка завершена"
}

# ============================================
# Установка системы
# ============================================
install_system() {
    header "УСТАНОВКА СИСТЕМЫ"
    
    # Установка базовых пакетов
    info "Установка базовой системы..."
    pacstrap -K /mnt base base-devel linux linux-firmware vim nano sudo \
        networkmanager dhcpcd iwd grub efibootmgr dosfstools \
        os-prober mtools git curl wget
    
    success "Базовая система установлена"
    
    # Генерация fstab
    info "Генерация fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
    success "fstab сгенерирован"
    
    # Настройка системы в chroot
    info "Настройка системы..."
    cat > /mnt/root/chroot_setup.sh << 'CHROOT'
#!/usr/bin/env bash

# Часовой пояс
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Локализация
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
for locale in "$@"; do
    sed -i "s/^#$locale/$locale/" /etc/locale.gen
done
locale-gen

# Язык системы
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Хостнейм
echo "archlinux" > /etc/hostname

# Hosts
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOF

# Пароль root
echo "root:root" | chpasswd

# Пользователь
useradd -m -G wheel,users,audio,video,storage -s /bin/bash user
echo "user:user" | chpasswd

# Sudo
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Bootloader
if [ -d /sys/firmware/efi ]; then
    # UEFI
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    # BIOS
    grub-install --target=i386-pc /dev/$(lsblk -ndo pkname $(findmnt -n -o SOURCE /))
fi

grub-mkconfig -o /boot/grub/grub.cfg

# Включение сервисов
systemctl enable NetworkManager
systemctl enable dhcpcd
systemctl enable iwd

exit
CHROOT
    
    chmod +x /mnt/root/chroot_setup.sh
    
    # Выполняем chroot с передачей локалей
    arch-chroot /mnt bash /root/chroot_setup.sh "${LOCALES[@]}"
    
    # Очистка
    rm /mnt/root/chroot_setup.sh
    
    success "Система настроена"
}

# ============================================
# Завершение
# ============================================
finish_installation() {
    header "$MSG_FINISH"
    
    # Размонтирование
    info "Размонтирование разделов..."
    umount -R /mnt
    
    echo -e "${GREEN}${BOLD}========================================${NC}"
    echo -e "${GREEN}${BOLD}  ✓ Установка Arch Linux завершена!${NC}"
    echo -e "${GREEN}${BOLD}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Данные для входа:${NC}"
    echo "  Root: root / root"
    echo "  User: user / user"
    echo ""
    echo -e "${YELLOW}После перезагрузки:${NC}"
    echo "  1. Извлеките установочный носитель"
    echo "  2. Выполните: systemctl reboot"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Перезагрузить сейчас? (y/N): "${NC})" reboot_now
    if [[ "$reboot_now" == "y" || "$reboot_now" == "Y" ]]; then
        info "Перезагрузка..."
        reboot
    fi
}

# ============================================
# Главная функция
# ============================================
main() {
    logo_show
    check_root
    select_language
    check_network
    select_locales
    select_disk
    select_partition_method
    install_system
    finish_installation
}

# Запуск
main "$@"

