# Run on LINUX:
# Create local folders, $ apt install borgbackup
mkdir -p "$BACKUP_PATH" "$UPLOAD_LOCATION/database-backup"

# Initialize LOCAL Borg repo (unencrypted, as in Immich docs)
borg init --encryption=none "$BACKUP_PATH/immich-borg"

# Run on remote server here mac
# We have already setup from linux machine to connect to mac like this: § ssh mac
# borg was installed on mac using homebrew: brew install borgbackup
borg init --encryption=none --remote-path /opt/homebrew/bin/borg "mac:/Users/hossein/Hossein/Backups/immich/immich-borg"