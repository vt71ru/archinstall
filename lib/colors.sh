#!/usr/bin/env bash
#
# ArchInstaller
# Colors and Text Formatting Module
#

# Проверка: если вывод идет не в терминал (например, в файл лога), отключаем цвета
if [[ -t 1 ]]; then
    # Основные цвета (Обычные)
    readonly CLR_RESET='\033[0m'
    readonly CLR_BLACK='\033[0;30m'
    readonly CLR_RED='\033[0;31m'
    readonly CLR_GREEN='\033[0;32m'
    readonly CLR_YELLOW='\033[0;33m'
    readonly CLR_BLUE='\033[0;34m'
    readonly CLR_PURPLE='\033[0;35m'
    readonly CLR_CYAN='\033[0;36m'
    readonly CLR_WHITE='\033[0;37m'

    # Жирные цвета (Bold)
    readonly CLR_B_RED='\033[1;31m'
    readonly CLR_B_GREEN='\033[1;32m'
    readonly CLR_B_YELLOW='\033[1;33m'
    readonly CLR_B_BLUE='\033[1;34m'
    readonly CLR_B_CYAN='\033[1;36m'
else
    readonly CLR_RESET=''
    readonly CLR_BLACK=''
    readonly CLR_RED=''
    readonly CLR_GREEN=''
    readonly CLR_YELLOW=''
    readonly CLR_BLUE=''
    readonly CLR_PURPLE=''
    readonly CLR_CYAN=''
    readonly CLR_WHITE=''
    readonly CLR_B_RED=''
    readonly CLR_B_GREEN=''
    readonly CLR_B_YELLOW=''
    readonly CLR_B_BLUE=''
    readonly CLR_B_CYAN=''
fi

########################################
# Функции форматированного вывода
########################################

# Информационное сообщение (Синий)
msg_info() {
    echo -e "${CLR_B_BLUE}[INFO]${CLR_RESET} $*"
}

# Успешное выполнение операции (Зеленый)
msg_success() {
    echo -e "${CLR_B_GREEN}[OK]${CLR_RESET} $*"
}

# Предупреждение (Желтый)
msg_warn() {
    echo -e "${CLR_B_YELLOW}[WARN]${CLR_RESET} $*" >&2
}

# Критическая ошибка (Красный)
msg_error() {
    echo -e "${CLR_B_RED}[ERROR]${CLR_RESET} $*" >&2
}

# Текст стадии/шага установки (Циан)
msg_step() {
    echo
    echo -e "${CLR_B_CYAN}>>> $*${CLR_RESET}"
}
