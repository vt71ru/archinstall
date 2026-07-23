#!/usr/bin/env bash

########################################
# Installer language selection
########################################

INSTALL_LANG=""
LANG_FILE=""

########################################
# Select language
########################################

select_language()
{
    echo
    echo "========================================"
    echo " ArchInstaller"
    echo " Installer language selection"
    echo " Выбор языка установщика"
    echo "========================================"
    echo

    echo " 1) English"
    echo " 2) Русский"
    echo " 3) Deutsch"
    echo " 4) Français"
    echo " 5) Español"
    echo " 6) Italiano"
    echo " 7) Polski"
    echo " 8) Português"
    echo

    while true; do
        read -rp "Select language [1-8]: " choice

        case "$choice" in
            1)
                INSTALL_LANG="english"
                break
                ;;
            2)
                INSTALL_LANG="russian"
                break
                ;;
            3)
                INSTALL_LANG="german"
                break
                ;;
            4)
                INSTALL_LANG="french"
                break
                ;;
            5)
                INSTALL_LANG="spanish"
                break
                ;;
            6)
                INSTALL_LANG="italian"
                break
                ;;
            7)
                INSTALL_LANG="polish"
                break
                ;;
            8)
                INSTALL_LANG="portuguese"
                break
                ;;
            *)
                echo "Invalid choice. Try again."
                ;;
        esac
    done

    LANG_FILE="${LANG_DIR}/${INSTALL_LANG}.conf"

    export INSTALL_LANG
    export LANG_FILE

    echo
    echo "Selected language: ${INSTALL_LANG}"

    if [[ ! -f "$LANG_FILE" ]]; then
        echo "[WARN] Language file not found:"
        echo "       $LANG_FILE"
    fi
}

########################################
# Load language file
########################################

load_language()
{
    if [[ -z "${LANG_FILE}" ]]; then
        echo "[ERROR] Language not selected"
        return 1
    fi

    if [[ ! -f "$LANG_FILE" ]]; then
        echo "[WARN] Using default language"
        return 0
    fi

    # shellcheck source=/dev/null
    source "$LANG_FILE"

    echo "Language loaded: ${LANG_FILE}"
}
