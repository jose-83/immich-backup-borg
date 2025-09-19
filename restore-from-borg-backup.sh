# Go to immich-borg folder where you have config file nad data folder
export BORG_REPO="/path/to/immich-borg"   # folder that contains config + data/
borg list "$BORG_REPO" # list of snapshots
borg info "$BORG_REPO::sabri-2025-09-12T23:53:57" # info about each snapshot
# copy your media and db dump

# You already have your docker-compose.yml and .env file
# if needed:
# docker compse down
# sudo rm -rf ./pgdata
docker compose up -d database
docker exec -i immich_postgres psql -U postgres -d postgres < immich-database.sql
docker compose up -d