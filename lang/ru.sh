#!/usr/bin/env bash
#
# ArchInstaller
# Russian language
#

[[ -n "${ARCHINSTALLER_RU_LOADED:-}" ]] && return
readonly ARCHINSTALLER_RU_LOADED=1


########################################
# Language information
########################################

LANG_NAME="Русский"
LANG_CODE="ru"


########################################
# Messages
########################################

msg_info()
{
    printf "\e[36m[ИНФО]\e[0m %s\n" "$*"
}


msg_success()
{
    printf "\e[32m[ OK ]\e[0m %s\n" "$*"
}


msg_warning()
{
    printf "\e[33m[WARN]\e[0m %s\n" "$*"
}


msg_error()
{
    printf "\e[31m[ERR ]\e[0m %s\n" "$*" >&2
}

########################################
# Interface
########################################

TXT_YES="Да"
TXT_NO="Нет"

TXT_BACK="Назад"
TXT_EXIT="Выход"
TXT_CANCEL="Отмена"
TXT_CONTINUE="Продолжить"

########################################
# Titles
########################################

TITLE_LANGUAGE="Выбор языка"
TITLE_NETWORK="Проверка сети"
TITLE_LOCALE="Настройка локали"
TITLE_DISK="Выбор диска"
TITLE_PARTITION="Разметка диска"
TITLE_INSTALL="Установка системы"
TITLE_BOOTLOADER="Загрузчик"
TITLE_USERS="Пользователи"
TITLE_FINISH="Завершение"

########################################
# Messages
########################################

MSG_LOADING_MODULES="Загрузка модулей..."
MSG_CHECKING_COMMANDS="Проверка команд..."
MSG_CHECKING_ENVIRONMENT="Проверка окружения..."
MSG_CHECKING_NETWORK="Проверка сети..."

MSG_INSTALLING_SYSTEM="Установка системы..."
MSG_FINISH="Установка завершена."

########################################
# Errors
########################################

ERR_ROOT="Требуются права root."
ERR_NETWORK="Нет подключения к сети."
ERR_DISK="Диск не найден."
ERR_INSTALL="Ошибка установки."
ERR_UNKNOWN="Неизвестная ошибка."
