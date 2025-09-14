#!/usr/bin/env bash

# safety flags:> -e: exit if any command fails. -u: treat unset variables as errors.
# -o pipefail: fail the whole pipeline if any command fails.
set -euo pipefail

########## EDIT THESE IF NEEDED ##########
UPLOAD_LOCATION="/home/hossein/immich-app/library"
BACKUP_PATH="/home/hossein/immich-backups"
DB_USERNAME="postgres"

REMOTE_HOST="mac"
REMOTE_BACKUP_PATH="/Users/hossein/Hossein/Backups/immich"
##########################################

# Point to borg on the Mac (adjust if different)
export BORG_REMOTE_PATH="/opt/homebrew/bin/borg"

MODE="${1:-both}"   # local | remote | both

LOG_DIR="$BACKUP_PATH/logs"
mkdir -p "$LOG_DIR"
STAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="$LOG_DIR/${STAMP}_${MODE}.log"

PG_CONTAINER="immich_postgres"   # change if your container name differs
DB_DUMP_DIR="$UPLOAD_LOCATION/borg-db-backup"
DB_DUMP_FILE="$DB_DUMP_DIR/immich-database.sql"

# Standalone DB dump copies on the Mac
REMOTE_DB_DIR="$REMOTE_BACKUP_PATH/db-dumps"
REMOTE_DB_KEEP=10  # keep latest 10 standalone .sql files

# Function to add timestamps to output
timestamp_output() {
  while IFS= read -r line; do
    echo "$(date -Is) $line"
  done
}

do_dump() {
  echo "[DB] Dumping Postgres from container '$PG_CONTAINER'..."
  mkdir -p "$DB_DUMP_DIR"
  docker exec -t "$PG_CONTAINER" \
    pg_dumpall --clean --if-exists --username="$DB_USERNAME" > "$DB_DUMP_FILE"
}

do_local() {
  echo "[LOCAL] Creating archive (no excludes)..."
  borg create "$BACKUP_PATH/immich-borg::{hostname}-{now}" "$UPLOAD_LOCATION"
  echo "[LOCAL] Pruning..."
  borg prune --keep-weekly=4 --keep-monthly=3 "$BACKUP_PATH/immich-borg"
  echo "[LOCAL] Compacting..."
  borg compact "$BACKUP_PATH/immich-borg"
}

do_remote_copy_db() {
  echo "[REMOTE-DB] Copying standalone DB dump to Mac..."
  ssh "$REMOTE_HOST" "mkdir -p \"$REMOTE_DB_DIR\""
  local remote_file="$REMOTE_DB_DIR/immich-database-${STAMP}.sql"
  rsync -e ssh -t "$DB_DUMP_FILE" "$REMOTE_HOST:$remote_file"
  echo "[REMOTE-DB] Pruning old standalone DB dumps (keep $REMOTE_DB_KEEP)..."
  local prune_start=$((REMOTE_DB_KEEP + 1))
  ssh "$REMOTE_HOST" "sh -lc 'cd \"$REMOTE_DB_DIR\" && ls -1t immich-database-*.sql 2>/dev/null | tail -n +$prune_start | xargs -r rm --'"
}

do_remote() {
  echo "[REMOTE] Creating archive on Mac (no excludes)..."
  borg create "$REMOTE_HOST:$REMOTE_BACKUP_PATH/immich-borg::{hostname}-{now}" "$UPLOAD_LOCATION"
  echo "[REMOTE] Pruning..."
  borg prune --keep-weekly=4 --keep-monthly=3 "$REMOTE_HOST:$REMOTE_BACKUP_PATH/immich-borg"
  echo "[REMOTE] Compacting..."
  borg compact "$REMOTE_HOST:$REMOTE_BACKUP_PATH/immich-borg"
}

{
  echo "=== $(date -Is) Immich Borg backup (mode=$MODE) ==="
  do_dump
  case "$MODE" in
    local)  do_local ;;
    remote) do_remote_copy_db; do_remote ;;
    both)   do_remote_copy_db; do_local; do_remote ;;
    *)      echo "Unknown mode: $MODE" >&2; exit 2 ;;
  esac
  echo "=== $(date -Is) Done (mode=$MODE) ==="
} 2>&1 | timestamp_output >> "$LOG_FILE"