#!/usr/bin/env bash
#
# ArchInstaller
# Language module
#

########################################
# Доступные языки
########################################

readonly LANGUAGES=(
    "English"
    "Русский"
)

readonly LANGUAGE_FILES=(
    "en.sh"
    "ru.sh"
)

########################################
# Выбор языка
########################################

select_language()
{
    section "Выбор языка"

    menu_select \
        "Выберите язык установщика" \
        "${LANGUAGES[@]}"

    LANGUAGE_FILE="${LANGUAGE_FILES[$((REPLY-1))]}"

    export LANGUAGE_FILE

    msg_success "Выбран язык: ${LANGUAGES[$((REPLY-1))]}"
}

########################################
# Загрузка словаря
########################################

load_language()
{
    local file="${LANG_DIR}/${LANGUAGE_FILE}"

    if [[ ! -f "$file" ]]; then
        msg_error "Языковой файл не найден: $file"
        return 1
    fi

    # shellcheck source=/dev/null
    source "$file"

    msg_success "Загружен словарь: ${LANGUAGE_FILE}"
}

########################################
# Получение перевода
########################################

lang()
{
    local key="$1"

    if [[ -n "${!key:-}" ]]; then
        printf '%s\n' "${!key}"
    else
        printf '%s\n' "$key"
    fi
}
