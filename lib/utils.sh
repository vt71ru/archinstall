#!/usr/bin/env bash
#
# ArchInstaller
# Utilities and Helper Functions Module
#

########################################
# Обязательные функции для каркаса
########################################

# Проверяет, запущен ли скрипт с правами root
check_root() {
    msg_info "Проверка прав суперпользователя..."
    
    if [[ $EUID -ne 0 ]]; then
        die "Этот скрипт должен быть запущен от имени root (используйте sudo)."
    fi
    
    msg_success "Права root подтверждены."
}

########################################
# Дополнительные системные утилиты
########################################

# Проверяет, примонтирована ли указанная директория
is_mounted() {
    local mount_point="$1"
    mountpoint -q "$mount_point"
}

# Безопасное выполнение команд с логированием (для отладки)
# Использование: run_cmd "Команда описания" pacman -Sy
run_cmd() {
    local desc="$1"
    shift
    
    msg_info "Выполняется: $desc..."
    
    if "$@" > /dev/null 2>&1; then
        msg_success "Успешно: $desc"
        return 0
    else
        msg_error "Ошибка при выполнении: $desc"
        return 1
    fi
}

# Инициализация логирования (вызывается опционально в bootstrap)
init_logging() {
    readonly LOG_FILE="${ROOT_DIR}/install.log"
    
    # Создаем или очищаем файл лога
    : > "$LOG_FILE"
    
    msg_info "Логирование процесса запущено. Файл лога: $LOG_FILE"
    
    # Дублируем стандартный вывод и ошибки в файл лога, сохраняя вывод на экран
    exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$LOG_FILE" >&2)
}
