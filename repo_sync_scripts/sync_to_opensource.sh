#!/bin/bash

# sync_to_opensource.sh
# This script syncs changes from the private repository to the open-source repository,
# while ensuring sensitive data is not transferred.

# Print log message with timestamp
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling
set -e
trap 'log_message "[ERROR] Script failed at line $LINENO"' ERR

# Start sync process
log_message "[LOG SyncRepo] ========= Starting sync from private to open-source repo"

# Make sure we have the latest changes from both repos
log_message "Fetching latest changes from origin (private repo)..."
git fetch origin

log_message "Fetching latest changes from opensource repo..."
git fetch opensource

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
log_message "Current branch: $CURRENT_BRANCH"

# Create a temporary branch for the sync
SYNC_BRANCH="opensource-sync-$(date +%Y%m%d%H%M%S)"
log_message "Creating temporary branch for sync: $SYNC_BRANCH"
git checkout -b $SYNC_BRANCH

# Pull latest changes from origin
log_message "Pulling latest changes from origin..."
git pull origin $CURRENT_BRANCH

# Show files with sensitive information that will be sanitized
log_message "The following files contain sensitive information and will be sanitized:"
echo "- lib/firebase_options.dart"
echo "- android/app/src/main/AndroidManifest.xml"
echo "- lib/pages/chat/api_config.dart"
echo "- lib/pages/discover/gebeta_maps_service.dart"
echo "- android/app/google-services.json"

# Ask for confirmation
read -p "Do you want to proceed with the sync? (y/n): " CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    log_message "Sync cancelled by user."
    git checkout $CURRENT_BRANCH
    git branch -D $SYNC_BRANCH
    exit 1
fi

# Replace API keys with placeholders (these are just examples - adjust as needed)
log_message "Sanitizing sensitive information..."

# Sanitize firebase_options.dart
if [ -f "lib/firebase_options.dart" ]; then
    log_message "Sanitizing lib/firebase_options.dart"
    # Replace API keys with placeholders
    sed -i 's/apiKey: .*/apiKey: "YOUR_API_KEY",/' lib/firebase_options.dart
    sed -i 's/appId: .*/appId: "YOUR_APP_ID",/' lib/firebase_options.dart
    sed -i 's/messagingSenderId: .*/messagingSenderId: "YOUR_MESSAGING_SENDER_ID",/' lib/firebase_options.dart
    sed -i 's/androidClientId: .*/androidClientId: "YOUR_ANDROID_CLIENT_ID",/' lib/firebase_options.dart
    sed -i 's/iosClientId: .*/iosClientId: "YOUR_IOS_CLIENT_ID",/' lib/firebase_options.dart
    sed -i 's/measurementId: .*/measurementId: "YOUR_MEASUREMENT_ID",/' lib/firebase_options.dart
fi

# Sanitize AndroidManifest.xml
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    log_message "Sanitizing android/app/src/main/AndroidManifest.xml"
    # Replace Google Maps API key
    sed -i 's/android:value="[^"]*"\/>/android:value="YOUR_GOOGLE_MAPS_API_KEY" \/>/' android/app/src/main/AndroidManifest.xml
fi

# Sanitize api_config.dart
if [ -f "lib/pages/chat/api_config.dart" ]; then
    log_message "Sanitizing lib/pages/chat/api_config.dart"
    # Replace OpenAI API key
    sed -i 's/openAIApiKey = .*/openAIApiKey = "YOUR_OPENAI_API_KEY";/' lib/pages/chat/api_config.dart
fi

# Sanitize gebeta_maps_service.dart
if [ -f "lib/pages/discover/gebeta_maps_service.dart" ]; then
    log_message "Sanitizing lib/pages/discover/gebeta_maps_service.dart"
    # Replace Gebeta Maps API key
    sed -i 's/_apiKey = .*/_apiKey = "YOUR_GEBETA_MAPS_API_KEY";/' lib/pages/discover/gebeta_maps_service.dart
fi

# Sanitize google-services.json
if [ -f "android/app/google-services.json" ]; then
    log_message "Sanitizing android/app/google-services.json"
    # This is a more complex JSON file, use a placeholder instead
    cat > android/app/google-services.json << EOF
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "aastu-map-project",
    "storage_bucket": "aastu-map-project.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_MOBILESDK_APP_ID",
        "android_client_info": {
          "package_name": "com.gdsc.aastu_map"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_OAUTH_CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "YOUR_OAUTH_CLIENT_ID",
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
EOF
fi

# Commit the sanitized changes
log_message "Committing sanitized changes..."
git add .
git commit -m "[Sync] Sanitized version for open-source repository"

# Push to the open-source repository
log_message "Pushing to open-source repository..."
git push opensource $SYNC_BRANCH:main

# Return to original branch
log_message "Returning to original branch: $CURRENT_BRANCH"
git checkout $CURRENT_BRANCH

# Clean up
log_message "Cleaning up temporary branch..."
git branch -D $SYNC_BRANCH

# Success message
log_message "[LOG SyncRepo] ========= Successfully synced sanitized changes to the open-source repository"
log_message "Private repo: https://github.com/GDSC-AASTU/aastu-map-mobile.git"
log_message "Open-source repo: https://github.com/GDSC-AASTU/aastu-map-opensource.git" 