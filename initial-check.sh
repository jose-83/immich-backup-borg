# Navigate to your Immich installation directory
cd /path/to/your/immich-app

# Check your current version
docker compose ps

# Identify your environment variables
cat .env
# UPLOAD_LOCATION=./library
# DB_DATA_LOCATION=./postgres
# IMMICH_VERSION=v1.135.3
# DB_PASSWORD=postgres

# Check disk space
df -h
# Check size of your upload location
du -sh ./library

# Check database size
docker exec immich_postgres psql -U postgres -c "SELECT pg_size_pretty(pg_database_size('immich'));"
# pg_size_pretty
# ----------------
#  406 MB
# (1 row)

# install restic ^ rsync
sudo apt install restic rsync -y

