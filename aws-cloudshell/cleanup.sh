#!/bin/bash

# AWS CloudShell Cache Cleanup Demo

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$BASE_DIR/test-cache"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/cleanup_$(date +%Y%m%d_%H%M%S).log"

RETENTION_DAYS=7
MODE="dry-run"

mkdir -p "$LOG_DIR"

if [[ "$1" == "--delete" ]]; then
    MODE="delete"
fi

echo "===== AWS CloudShell Cleanup =====" | tee -a "$LOG_FILE"
echo "Date: $(date)" | tee -a "$LOG_FILE"
echo "Mode: $MODE" | tee -a "$LOG_FILE"

if [[ ! -d "$TEST_DIR" ]]; then
    echo "Test directory not found." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Scanning: $TEST_DIR" | tee -a "$LOG_FILE"

mapfile -t FILES < <(
    find "$TEST_DIR" -type f -name "*.tmp" -mmin +"$((RETENTION_DAYS * 24 * 60))"
)

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No old temporary files found." | tee -a "$LOG_FILE"
    exit 0
fi

echo "Files identified: ${#FILES[@]}" | tee -a "$LOG_FILE"

for file in "${FILES[@]}"; do
    echo "$file" | tee -a "$LOG_FILE"
done

if [[ "$MODE" == "dry-run" ]]; then
    echo "Dry run complete. No files deleted." | tee -a "$LOG_FILE"
    exit 0
fi

read -r -p "Delete these files? (yes/no): " CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
    for file in "${FILES[@]}"; do
        if rm -- "$file"; then
            echo "Deleted: $file" | tee -a "$LOG_FILE"
        else
            echo "Failed: $file" | tee -a "$LOG_FILE"
        fi
    done
else
    echo "Deletion cancelled." | tee -a "$LOG_FILE"
fi

echo "Cleanup completed." | tee -a "$LOG_FILE"
