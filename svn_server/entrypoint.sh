#!/bin/sh

SVN_REPO_DIR="/svn/repositories"
DUMP_DIR="/svn/dump_files"


# List of repositories
REPO_LIST="repo1 repo2 repo3"

# Ensure the repositories directory exists
mkdir -p "$SVN_REPO_DIR" "$DUMP_DIR"

for REPO in $REPO_LIST; do
    REPO_PATH="$SVN_REPO_DIR/$REPO"
    
    if [ ! -d "$REPO_PATH/db" ]; then
        echo "Creating new SVN repository: $REPO"
        svnadmin create "$REPO_PATH" --fs-type fsfs

        # Load dump file if available
        if [ -f "$DUMP_DIR/repo_$REPO.svn_dump" ]; then
            echo "Loading SVN dump for $REPO..."
            svnadmin load "$REPO_PATH" < "$DUMP_DIR/repo_$REPO.svn_dump"
            echo "Loaded dump for $REPO."
        fi
    else
        echo "Repository $REPO already exists. Skipping initialization."
    fi
done

echo "Setting permissions..."
chgrp -R vboxsf "$SVN_REPO_DIR"
chmod -R 770 "$SVN_REPO_DIR"
echo "Permissions set."

echo "Starting cron service..."
cron -f &

echo "Starting SSH server..."
/usr/sbin/sshd -D
