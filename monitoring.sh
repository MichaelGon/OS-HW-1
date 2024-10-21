#!/bin/bash

PID_FILE="/tmp/monitor.pid"

OUTPUT_DIR="./monitoring_logs"

create_new_csv() {
    mkdir -p "$OUTPUT_DIR"
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    CSV_FILE="$OUTPUT_DIR/monitoring_$TIMESTAMP.csv"
    echo "          Timestamp,    Used Space,  Free Inodes" > "$CSV_FILE"
}

monitor() {
    while true; do
        CURRENT_DATE=$(date "+%Y-%m-%d")
        if [[ "$CURRENT_DATE" != "$LAST_DATE" ]]; then
            create_new_csv
            LAST_DATE="$CURRENT_DATE"
        fi
        
        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
        USED_SPACE=$(df / | awk 'NR==2 {print $5}')
        FREE_INODES=$(df -i / | awk 'NR==2 {print $4}')
        
        echo "$TIMESTAMP,            $USED_SPACE,    $FREE_INODES" >> "$CSV_FILE"
        sleep 20
    done
}

case "$1" in
    START)
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Мониторинг уже запущен с PID=$(cat $PID_FILE)"
        else
            create_new_csv
            LAST_DATE=$(date "+%Y-%m-%d")
            monitor & 
            echo $! > "$PID_FILE"
            echo "Мониторинг запущен с PID=$!"
        fi
        ;;
    STOP)
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            kill $(cat "$PID_FILE")
            rm "$PID_FILE"
            echo "Мониторинг остановлен"
        else
            echo "Мониторинг не работает"
        fi
        ;;
    STATUS)
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Мониторинг запущен с PID=$(cat $PID_FILE)"
        else
            echo "Мониторинг не работает"
        fi
        ;;
    *)
        echo "Использование: $0 {START|STOP|STATUS}"
        exit 1
        ;;
esac

exit 0
