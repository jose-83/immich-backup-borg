## Borg installation and setup
To install on Linux Debian/Ubuntu:
```bash
apt install borgbackup
BACKUP_PATH=/path/to/backup/folder
mkdir -p "$BACKUP_PATH" "$BACKUP_PATH/database-backup"

# Initialize LOCAL Borg repo (unencrypted, as in Immich docs)
borg init --encryption=none "$BACKUP_PATH/immich-borg"
```
