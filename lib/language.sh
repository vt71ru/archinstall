#!/usr/bin/env bash
#
# ArchInstaller
# Installer language module
#

########################################
# Языки установщика
########################################

readonly LANGUAGES=(
    "Русский"
    "English"
)

readonly LANGUAGE_FILES=(
    "ru.sh"
    "en.sh"
)

########################################
# Выбор языка
########################################

select_language()
{
    section "Язык установщика"

    menu_select \
        "Выберите язык" \
        "${LANGUAGES[@]}"

    LANGUAGE_FILE="${LANGUAGE_FILES[$((REPLY-1))]}"

    export LANGUAGE_FILE
}

########################################
# Загрузка языка
########################################

load_language()
{
    local file="${LANG_DIR}/${LANGUAGE_FILE}"

    [[ -f "$file" ]] \
        || return 1

    source "$file"

    msg_success "Язык загружен"
}
