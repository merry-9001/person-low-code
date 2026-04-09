#!/usr/bin/env sh

set -eu

APP_IMAGE="${APP_IMAGE:-your-dockerhub-username/person-low-code:latest}"

echo "Deploy image: ${APP_IMAGE}"

docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d --remove-orphans

echo "Deploy finished successfully."
