docker compose -f docker-compose.dev.yml down
rm -rf ./docker/postgres/data
docker compose -f docker-compose.dev.yml up -d