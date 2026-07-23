#!/usr/bin/env bash
#
# ArchInstaller
# Global Configuration File
#

########################################
# Локализация и региональные настройки
########################################

# Язык установщика по умолчанию (ru / en)
DEFAULT_LANG="ru"

# Часовой пояс (в формате Zone/Subzone)
TARGET_TIMEZONE="Europe/Moscow"

# Системная локаль и кодировка для /etc/locale.gen
TARGET_LOCALE="ru_RU.UTF-8 UTF-8"
TARGET_LANG="ru_RU.UTF-8"

# Консольный шрифт и раскладка клавиатуры (vconsole.conf)
TARGET_KEYMAP="ru"
TARGET_FONT="cyr-sun16"

########################################
# Настройки сети и системы
########################################

# Имя компьютера (Hostname)
TARGET_HOSTNAME="arch-linux"

# Использовать сетевой менеджер (NetworkManager / systemd-networkd)
NETWORK_MANAGER="NetworkManager"

########################################
# Конфигурация дисков и ФС
########################################

# Файловая система для корневого раздела (ext4 / btrfs / xfs)
TARGET_FS="ext4"

# Использовать файл подкачки (Swap)? 
# 0 — отключено, либо укажите размер в гигабайтах (например, 4)
SWAP_SIZE_GB=4

# Размеры служебных разделов (в мегабайтах)
BOOT_PART_SIZE_MB=512

########################################
# Список устанавливаемых пакетов
########################################

# Базовые системные пакеты (для утилиты pacstrap)
BASE_PACKAGES=(
    base
    linux
    linux-firmware
    intel-ucode # Измените на amd-ucode, если у вас процессор AMD
)

# Системные утилиты и драйверы сети
SYSTEM_PACKAGES=(
    networkmanager
    sudo
    neovim
    git
    openssh
    bash-completion
)

# Профили окружения (будут прочитаны скриптом для установки DE)
# Возможные значения: none / gnome / kde / xfce / i3
DESKTOP_ENVIRONMENT="none"

########################################
# Пользовательские учетные записи
########################################

# Имя основного пользователя (не root)
DEFAULT_USER="archuser"

# Группы, в которые будет добавлен пользователь по умолчанию
USER_GROUPS="wheel,storage,power"
