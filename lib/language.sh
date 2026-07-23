#!/usr/bin/env bash
#
# ArchInstaller
# Installer language module
#

########################################
# Languages
########################################

readonly LANGUAGES=(
    "Русский"
    "English"
)

readonly LANGUAGE_FILES=(
    "ru.sh"
    "en.sh"
)

LANGUAGE_FILE="${LANGUAGE_FILE:-}"

########################################
# Language selection
########################################

select_language()
{
    local index

    section "Язык установщика"

    menu_select \
        "Выберите язык" \
        "${LANGUAGES[@]}"

    index=$((REPLY - 1))

    [[ -n "${LANGUAGE_FILES[$index]:-}" ]] \
        || die "Некорректный выбор языка"

    LANGUAGE_FILE="${LANGUAGE_FILES[$index]}"

    export LANGUAGE_FILE


    msg_success "Выбран язык: ${LANGUAGES[$index]}"
}

########################################
# Language loading
########################################

load_language()
{
    local file

    [[ -n "${LANGUAGE_FILE:-}" ]] \
        || die "Язык не выбран"

    file="${LANG_DIR}/${LANGUAGE_FILE}"

    [[ -f "$file" ]] \
        || die "Файл языка отсутствует: $file"

    # shellcheck disable=SC1090
    source "$file"

    msg_success "Язык загружен: $LANGUAGE_FILE"
}
