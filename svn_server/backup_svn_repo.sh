#!/bin/bash

# Define backup directories
SVN_REPO_DIR="/svn/repositories"
BACKUP_DIR="/svn/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

# Ensure backup directory exists
mkdir -p "$BACKUP_PATH"

# List all repositories
REPO_LIST=$(ls "$SVN_REPO_DIR")

echo "Starting SVN repositories backup..."

for REPO in $REPO_LIST; do
    REPO_PATH="$SVN_REPO_DIR/$REPO"
    BACKUP_FILE="$BACKUP_PATH/${REPO}.svn_dump"

    # Check if it's a valid SVN repository
    if [ -d "$REPO_PATH/db" ]; then
        echo "Backing up repository: $REPO"
        svnadmin dump "$REPO_PATH" > "$BACKUP_FILE"
    else
        echo "Skipping $REPO - Not a valid SVN repository."
    fi
done

# Compress the backup
# tar -czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "backup_$TIMESTAMP"
# rm -rf "$BACKUP_PATH"

# echo "Backup completed: $BACKUP_PATH.tar.gz"

# Optional: Remove old backups (keep last 5 backups)
# ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +6 | xargs rm -f

# echo "Old backups cleaned up."
