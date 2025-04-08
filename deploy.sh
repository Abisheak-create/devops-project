#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$BRANCH" == "dev" ]]; then
    COMPOSE_FILE="docker-compose.dev.yml"
elif [[ "$BRANCH" == "master" ]]; then
    COMPOSE_FILE="docker-compose.prod.yml"
else
    echo "No deployment config for branch: $BRANCH"
    exit 1
fi

echo "Tearing down existing containers..."
docker-compose -f $COMPOSE_FILE down --volumes --remove-orphans || true
docker system prune -f || true

echo "Deploying application with: $COMPOSE_FILE"
docker-compose -f $COMPOSE_FILE up -d --build
docker ps
