#!/usr/bin/env bash
set -u

TARGET_DIR="$HOME/cache-cleanup-project/test-cache"
DAYS=7
LOG_FILE="$HOME/cache-cleanup-project/cleanup.log"
MODE="${1:-dry-run}"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" \
        | tee -a "$LOG_FILE"
}

# Safety checks
if [[ ! -d "$TARGET_DIR" || -L "$TARGET_DIR" ]]; then
    log "ERROR: Target directory is missing or is a symbolic link."
    exit 1
fi

if [[ "$TARGET_DIR" != "$HOME/cache-cleanup-project/test-cache" ]]; then
    log "ERROR: Unexpected target directory."
    exit 1
fi

if [[ "$MODE" != "dry-run" && "$MODE" != "--delete" ]]; then
    echo "Usage: $0 [--delete]"
    exit 1
fi

if [[ "$MODE" == "--delete" ]]; then
    read -r -p "Type DELETE to remove eligible test files: " CONFIRM
    if [[ "$CONFIRM" != "DELETE" ]]; then
        log "Deletion cancelled."
        exit 0
    fi
fi

log "Cache cleanup started."
log "Target directory: $TARGET_DIR"
log "Age threshold: $DAYS days"

FOUND=false

while IFS= read -r -d '' file; do
    FOUND=true

    if [[ "$MODE" == "--delete" ]]; then
        if rm -- "$file"; then
            log "Deleted: $file"
        else
            log "ERROR: Could not delete: $file"
        fi
    else
        log "DRY RUN - Candidate for cleanup: $file"
    fi
done < <(
    find "$TARGET_DIR" -maxdepth 1 -type f -name '*.tmp' \
        -mtime "+$((DAYS - 1))" -print0
)

if [[ "$FOUND" == false ]]; then
    log "No eligible files found."
fi

log "Cache cleanup finished."
