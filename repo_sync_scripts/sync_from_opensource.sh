#!/bin/bash

# sync_from_opensource.sh
# This script syncs changes from the open-source repository back to the private repository,
# while preserving sensitive information

# Print log message with timestamp
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling
set -e
trap 'log_message "[ERROR] Script failed at line $LINENO"' ERR

# Start sync process
log_message "[LOG SyncRepo] ========= Starting sync from open-source to private repo"

# Make sure we have the latest changes from both repos
log_message "Fetching latest changes from origin (private repo)..."
git fetch origin

log_message "Fetching latest changes from opensource repo..."
git fetch opensource

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
log_message "Current branch: $CURRENT_BRANCH"

# Create a temporary branch for the sync
SYNC_BRANCH="private-sync-$(date +%Y%m%d%H%M%S)"
log_message "Creating temporary branch for sync: $SYNC_BRANCH"
git checkout -b $SYNC_BRANCH

# List sensitive files that should be preserved
SENSITIVE_FILES=(
    "lib/firebase_options.dart"
    "android/app/src/main/AndroidManifest.xml"
    "lib/pages/chat/api_config.dart"
    "lib/pages/discover/gebeta_maps_service.dart"
    "android/app/google-services.json"
)

# Backup sensitive files
log_message "Backing up sensitive files..."
mkdir -p .temp_backup
for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        log_message "Backing up $file"
        mkdir -p ".temp_backup/$(dirname "$file")"
        cp "$file" ".temp_backup/$file"
    fi
done

# Pull changes from the open-source repository
log_message "Pulling changes from open-source repository..."
git pull opensource main --no-rebase

# Restore sensitive files
log_message "Restoring sensitive files..."
for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f ".temp_backup/$file" ]; then
        log_message "Restoring $file"
        cp ".temp_backup/$file" "$file"
    fi
done

# Show restored files
log_message "The following sensitive files were preserved:"
for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "- $file"
    fi
done

# Ask for confirmation
read -p "Do you want to commit these changes to the private repository? (y/n): " CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    log_message "Sync cancelled by user."
    # Clean up
    git checkout $CURRENT_BRANCH
    git branch -D $SYNC_BRANCH
    rm -rf .temp_backup
    exit 1
fi

# Commit the merged changes
log_message "Committing merged changes..."
git add .
git commit -m "[Sync] Merged changes from open-source repository"

# Ask which branch to push to
read -p "Enter the branch name to push to (default: $CURRENT_BRANCH): " TARGET_BRANCH
TARGET_BRANCH=${TARGET_BRANCH:-$CURRENT_BRANCH}

# Push to the private repository
log_message "Pushing to private repository branch: $TARGET_BRANCH..."
git push origin $SYNC_BRANCH:$TARGET_BRANCH

# Clean up
log_message "Returning to original branch: $CURRENT_BRANCH"
git checkout $CURRENT_BRANCH

log_message "Cleaning up temporary branch and backup files..."
git branch -D $SYNC_BRANCH
rm -rf .temp_backup

# Success message
log_message "[LOG SyncRepo] ========= Successfully synced changes from open-source repository to private repository"
log_message "Open-source repo: https://github.com/GDSC-AASTU/aastu-map-opensource.git"
log_message "Private repo: https://github.com/GDSC-AASTU/aastu-map-mobile.git"
log_message "Target branch: $TARGET_BRANCH" 