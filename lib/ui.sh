#!/usr/bin/env bash
#
# ArchInstaller
# User interface module
#

########################################
# Logo
########################################

logo_show()
{
    echo -e "
-------------------------------------------------------------------------

    _             _     _           _
   / \   _ __ ___| |__ (_)_ __  ___| |_
  / _ \ | '__/ __| '_ \| | '_ \/ __| __|
 / ___ \| | | (__| | | | | | | \__ \ |_
/_/   \_\_|  \___|_| |_|_|_| |_|___/\__|

-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------
"
}

########################################
# Messages
########################################

msg_info()
{
    echo -e "${BLUE}[INFO]${RESET} $*"
}

msg_success()
{
    echo -e "${GREEN}[ OK ]${RESET} $*"
}

msg_warning()
{
    echo -e "${YELLOW}[WARN]${RESET} $*"
}

msg_error()
{
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

########################################
# Section title
########################################

section()
{
    echo
    echo -e "${CYAN}========== $* ==========${RESET}"
    echo
}

########################################
# Horizontal line
########################################

line()
{
    echo "-----------------------------------------"
}

########################################
# Pause
########################################

press_enter()
{
    read -rp "Нажмите Enter для продолжения..."
}

########################################
# Confirmation
########################################

confirm()
{
    local answer

    while true; do
        read -rp "$1 [y/N]: " answer

        case "$answer" in
            y|Y|yes|YES)
                return 0
                ;;
            n|N|no|NO|"")
                return 1
                ;;
            *)
                echo "Введите y или n"
                ;;
        esac
    done
}

########################################
# Menu selection
########################################

menu_select()
{
    local title="$1"
    shift

    local options=("$@")
    local choice
    local i

    echo
    echo "$title"
    echo

    i=1

    for item in "${options[@]}"; do
        echo "$i) $item"
        ((i++))
    done

    echo

    while true; do
        read -rp "Выбор: " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] \
            && (( choice >= 1 && choice <= ${#options[@]} )); then

            REPLY="$choice"
            return 0
        fi

        echo "Неверный выбор"
    done
}

########################################
# Progress
########################################

progress()
{
    local message="$1"

    echo -ne "\r${CYAN}[...]${RESET} $message"
}

progress_done()
{
    echo
}

########################################
# Clear screen
########################################

ui_clear()
{
    clear
}
