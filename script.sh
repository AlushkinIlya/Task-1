#!/bin/bash

# Функция для вывода пользователей и их домашних директорий
list_users() {
    cut -d: -f1,6 /etc/passwd | sort
}

# Функция для вывода запущенных процессов
list_processes() {
    ps -eo pid,comm --sort=pid
}

# Функция для вывода справки
print_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --users              List users and their home directories."
    echo "  -p, --processes          List running processes sorted by their PID."
    echo "  -h, --help               Display this help message."
    echo "  -l PATH, --log PATH      Redirect output to the specified file."
    echo "  -e PATH, --errors PATH   Redirect error output to the specified file."
    echo ""
    exit 0
}

# Проверка доступа к пути
check_path() {
    local path=$1
    if [ ! -d "$(dirname "$path")" ]; then
        echo "Error: Directory $(dirname "$path") does not exist."
        exit 1
    fi
}

# Основная программа
LOG_PATH=""
ERROR_PATH=""
ACTION=""

while [[ "$1" != "" ]]; do
    case "$1" in
        -u | --users )
            ACTION="users"
            ;;
        -p | --processes )
            ACTION="processes"
            ;;
        -h | --help )
            ACTION="help"
            ;;
        -l | --log )
            shift
            LOG_PATH=$1
            check_path "$LOG_PATH"
            ;;
        -e | --errors )
            shift
            ERROR_PATH=$1
            check_path "$ERROR_PATH"
            ;;
        * )
            echo "Error: Invalid option '$1'"
            print_help
            ;;
    esac
    shift
done

# Обработка перенаправления вывода
if [ -n "$LOG_PATH" ]; then
    exec 1>>"$LOG_PATH"
fi

if [ -n "$ERROR_PATH" ]; then
    exec 2>>"$ERROR_PATH"
fi

# Выполнение соответствующей функции
case "$ACTION" in
    users )
        list_users
        ;;
    processes )
        list_processes
        ;;
    help )
        print_help
        ;;
    * )
        echo "Error: No action specified."
        print_help
        ;;
esac
