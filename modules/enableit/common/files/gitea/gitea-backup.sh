#!/bin/bash
set -euo pipefail

# Configuration
BACKUP_DIR="/opt/obmondo/backup"
GITEA_CONTAINER="gitea"
GITEA_USER="git"
GITEA_DUMP_FILENAME="gitea-dump"
MAX_LOCAL_BACKUPS=1 # Maximum number of local backups to retain
MAX_S3_BACKUPS=3 # Maximum number of S3 backups to retain
S3_BUCKET="s3://gitea-backup/"
S3_ENDPOINT="https://s3.obmondo.com"
SOURCE_DIR="/opt/gitea/data/git"

# Logging function
log() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1"
    logger -t gitea-backup "$1"  # Send message to syslog
}

# 1. Clean disk before creating a new backup
check_and_clean_source() {

    # Clean Gitea container's temp folder (Always do this to prevent stuck files)
    log "Cleaning Gitea container /tmp directory..."
    docker exec -u "$GITEA_USER" "$GITEA_CONTAINER" bash -c "rm -rf /tmp/gitea-dump-*" || true

    # Remove leftover zips on the HOST source directory
    rm -f "$SOURCE_DIR"/gitea-dump-*.zip
}

# 2. Create local backup directory
create_backup_directory() {
    mkdir -p "$BACKUP_DIR"
    log "Backup directory created: $BACKUP_DIR"
}

# 3. Dump Gitea data (Generates the NEW backup)
dump_gitea_data() {
    log "Dumping Gitea data..."
    docker exec -u "$GITEA_USER" "$GITEA_CONTAINER" bash -c \
        "cd ~ && /app/gitea/gitea dump -c /data/gitea/conf/app.ini"
}

# 4. Move the NEW dump and upload to S3
copy_latest_dump() {
    # Move the newly generated backup
    if ls "$SOURCE_DIR"/gitea-dump-*.zip 1> /dev/null 2>&1; then
        mv "$SOURCE_DIR"/gitea-dump-*.zip "$BACKUP_DIR"
    else
        log "Error: New backup file was not found after dump command."
        exit 1
    fi

    local latest_dump=$(ls -t "$BACKUP_DIR"/gitea-dump-*.zip 2>/dev/null | head -n 1)

    if [ -n "$latest_dump" ]; then
        log "Latest dump moved to $BACKUP_DIR: $(basename "$latest_dump")"
        log "Moving backup to S3..."
        
        aws s3 cp "$latest_dump" "$S3_BUCKET" --endpoint-url="$S3_ENDPOINT"

        perform_s3_backup_rotation
    else
        log "No backup found to copy."
    fi
}

# 5. Rotate S3 backups
perform_s3_backup_rotation() {
    log "Performing S3 backup rotation: Deleting older backups..."
    s3_backups=$(aws s3 ls "$S3_BUCKET" --recursive --endpoint-url="$S3_ENDPOINT" | sort -k1,2 | awk '{print $4}')
    num_s3_backups=$(echo "$s3_backups" | wc -l)

    if [ "$num_s3_backups" -gt "$MAX_S3_BACKUPS" ]; then
        num_s3_to_remove=$((num_s3_backups - MAX_S3_BACKUPS))
        older_s3_backups=$(echo "$s3_backups" | head -n "$num_s3_to_remove")

        for older_backup in $older_s3_backups; do
            aws s3 rm "$S3_BUCKET$older_backup" --endpoint-url="$S3_ENDPOINT"
            log "Removed old S3 backup: $older_backup"
        done
    fi
}

# Function to perform local backup rotation
perform_local_backup_rotation() {
    backups=("$BACKUP_DIR"/*)
    num_backups=${#backups[@]}

    if [ "$num_backups" -gt "$MAX_LOCAL_BACKUPS" ]; then
        num_local_to_remove=$((num_backups - MAX_LOCAL_BACKUPS))
        log "Performing local backup rotation: Removing $num_local_to_remove old backup(s)..."

        for ((i = 0; i < num_local_to_remove; i++)); do
            rm "${backups[i]}"
            log "Removed old local backup: ${backups[i]}"
        done
    fi
}

# Execute functions directly
check_and_clean_source
create_backup_directory
dump_gitea_data
copy_latest_dump
perform_local_backup_rotation
log "Backup process completed."
