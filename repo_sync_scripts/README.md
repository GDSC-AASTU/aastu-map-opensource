# Repository Synchronization Scripts

These scripts help synchronize changes between the private repository and the open-source repository while handling sensitive information appropriately.

## Available Scripts

### 1. sync_to_opensource.sh

This script syncs changes from the private repository to the open-source repository while sanitizing sensitive information.

**Usage:**
```bash
./repo_sync_scripts/sync_to_opensource.sh
```

**What it does:**
- Creates a temporary branch from your current branch
- Fetches the latest changes from both repositories
- Sanitizes sensitive files by replacing API keys with placeholders
- Commits the sanitized changes
- Pushes the changes to the open-source repository
- Cleans up temporary files and branches

### 2. sync_from_opensource.sh

This script syncs changes from the open-source repository back to the private repository while preserving sensitive information.

**Usage:**
```bash
./repo_sync_scripts/sync_from_opensource.sh
```

**What it does:**
- Creates a temporary branch for the sync
- Backs up sensitive files (API keys, credentials, etc.)
- Pulls changes from the open-source repository
- Restores the backed-up sensitive files
- Commits the merged changes with preserved sensitive information
- Pushes to your chosen branch in the private repository
- Cleans up temporary files and branches

## Sensitive Files

The following files are treated as sensitive and handled specially during synchronization:

- `lib/firebase_options.dart`
- `android/app/src/main/AndroidManifest.xml`
- `lib/pages/chat/api_config.dart`
- `lib/pages/discover/gebeta_maps_service.dart`
- `android/app/google-services.json`

## Best Practices

1. Always review changes before syncing between repositories
2. Regularly check that the sanitization process is working correctly
3. If new sensitive files are added to the project, update both scripts to include them
4. Test the scripts in a safe environment before using them on important branches

## Troubleshooting

- If you encounter git errors, make sure both repositories are properly configured as remotes
- If sanitization fails, check the sed patterns in the scripts and adjust as needed
- If conflicts occur during sync, resolve them manually before continuing 