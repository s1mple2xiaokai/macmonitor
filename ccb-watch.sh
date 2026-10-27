#!/bin/bash
# CCB 任务状态监控脚本
# 用法: ccb-watch <task_id>

TASK_ID="${1:-}"
if [ -z "$TASK_ID" ]; then
    echo "用法: ccb-watch <task_id>"
    echo "或: ccb-watch --all"
    exit 1
fi

if [ "$TASK_ID" = "--all" ]; then
    # 监控所有进行中的任务
    echo "监控所有 CCB 任务 (Ctrl+C 退出)..."
    while true; do
        clear
        echo "=== CCB 任务状态 $(date) ==="
        ls -t /var/folders/m7/_4l_4f7j6rx8gdxlph67zhw80000gn/T/ccb-tasks/ask-* 2>/dev/null | head -5 | while read f; do
            task_id=$(basename "$f" | sed 's/ask-//')
            if [ -f "$f.status" ]; then
                status=$(cat "$f.status" 2>/dev/null)
                echo "  $task_id: $status"
            fi
        done
        sleep 3
    done
else
    # 监控指定任务
    STATUS_FILE="/var/folders/m7/_4l_4f7j6rx8gdxlph67zhw80000gn/T/ccb-tasks/ask-${TASK_ID}.status"
    LOG_FILE="/var/folders/m7/_4l_4f7j6rx8gdxlph67zhw80000gn/T/ccb-tasks/ask-${TASK_ID}.log"

    echo "监控任务 $TASK_ID ..."

    while true; do
        if [ -f "$STATUS_FILE" ]; then
            status=$(cat "$STATUS_FILE" 2>/dev/null)
            echo "状态: $status"
            if [ "$status" = "completed" ] || [ "$status" = "failed" ]; then
                echo "=== 任务完成 ==="
                if [ -f "$LOG_FILE" ]; then
                    echo "--- 日志 ---"
                    tail -20 "$LOG_FILE"
                fi
                break
            fi
        fi
        sleep 2
    done
fi
