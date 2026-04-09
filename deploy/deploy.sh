#!/usr/bin/env sh

set -eu

BRANCH="${1:-main}"

echo "Deploy branch: ${BRANCH}"
echo "Working directory: $(pwd)"

git fetch origin "${BRANCH}"
git checkout "${BRANCH}"
git pull --ff-only origin "${BRANCH}"

APP_IMAGE="${APP_IMAGE:-your-dockerhub-username/person-low-code:latest}"
export APP_IMAGE

echo "Deploy image: ${APP_IMAGE}"

docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d --remove-orphans

echo "Deploy finished successfully."
