```bash
#!/usr/bin/env bash
#
# Русская локализация ArchInstaller
#

########################################
# Название языка
########################################

readonly LANG_NAME="Русский"
readonly LANG_CODE="ru"

########################################
# Цветной вывод сообщений
########################################

msg_info()
{
    printf "\e[34m[ИНФО]\e[0m %s\n" "$*"
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
# Общие строки
########################################

readonly TXT_YES="Да"
readonly TXT_NO="Нет"
readonly TXT_BACK="Назад"
readonly TXT_EXIT="Выход"
readonly TXT_CANCEL="Отмена"
readonly TXT_CONTINUE="Продолжить"

########################################
# Заголовки
########################################

readonly TITLE_WELCOME="Добро пожаловать в ArchInstaller"
readonly TITLE_LANGUAGE="Выбор языка"
readonly TITLE_LOCALE="Настройка локали"
readonly TITLE_NETWORK="Проверка сети"
readonly TITLE_DISK="Выбор диска"
readonly TITLE_PARTITION="Разметка диска"
readonly TITLE_INSTALL="Установка системы"
readonly TITLE_BOOTLOADER="Установка загрузчика"
readonly TITLE_USERS="Создание пользователя"
readonly TITLE_FINISH="Завершение установки"

########################################
# Сообщения
########################################

readonly MSG_LOADING_MODULES="Загрузка модулей..."
readonly MSG_CHECKING_COMMANDS="Проверка необходимых команд..."
readonly MSG_CHECKING_ENVIRONMENT="Проверка окружения..."
readonly MSG_CHECKING_NETWORK="Проверка подключения к Интернету..."
readonly MSG_SELECT_DISK="Выберите диск для установки."
readonly MSG_SELECT_METHOD="Выберите способ разметки диска."
readonly MSG_PREPARING_DISKS="Подготовка разделов..."
readonly MSG_INSTALLING_SYSTEM="Установка базовой системы..."
readonly MSG_INSTALLING_BOOTLOADER="Установка загрузчика..."
readonly MSG_CREATING_USERS="Создание пользователей..."
readonly MSG_FINISH="Установка успешно завершена."
readonly MSG_REBOOT="Теперь можно перезагрузить компьютер."

########################################
# Подтверждения
########################################

readonly ASK_CONTINUE="Продолжить?"
readonly ASK_FORMAT="Все данные на выбранном диске будут уничтожены. Продолжить?"
readonly ASK_REBOOT="Перезагрузить компьютер сейчас?"

########################################
# Ошибки
########################################

readonly ERR_ROOT="Установщик должен быть запущен от имени root."
readonly ERR_NETWORK="Отсутствует подключение к Интернету."
readonly ERR_DISK="Не удалось определить диск."
readonly ERR_PARTITION="Ошибка разметки диска."
readonly ERR_INSTALL="Ошибка установки системы."
readonly ERR_BOOTLOADER="Ошибка установки загрузчика."
readonly ERR_USER="Ошибка создания пользователя."
readonly ERR_UNKNOWN="Неизвестная ошибка."

########################################
# Успешные действия
########################################

readonly OK_ENVIRONMENT="Окружение проверено."
readonly OK_NETWORK="Сетевое подключение активно."
readonly OK_PARTITION="Разделы успешно созданы."
readonly OK_INSTALL="Базовая система установлена."
readonly OK_BOOTLOADER="Загрузчик установлен."
readonly OK_USER="Пользователь создан."
readonly OK_FINISH="Установка завершена успешно."
```

