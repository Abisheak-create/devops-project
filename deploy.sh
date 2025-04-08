#!/bin/bash

set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" == "dev" ]; then
    PORT="8081"
    COMPOSE_FILE="docker-compose.dev.yml"
elif [ "$BRANCH" == "master" ]; then
    PORT="8082"
    COMPOSE_FILE="docker-compose.prod.yml"
else
    echo "Unsupported branch: $BRANCH"
    exit 1
fi

# Stop and remove old containers on the port
CONTAINER_ID=$(docker ps -q --filter "publish=${PORT}")
if [ ! -z "$CONTAINER_ID" ]; then
    echo "Stopping container on port $PORT"
    docker stop $CONTAINER_ID
    docker rm $CONTAINER_ID
fi

# Clean up old containers and deploy
echo "Tearing down previous deployment"
docker-compose -f $COMPOSE_FILE down --volumes --remove-orphans || true
docker system prune -f || true

echo "Starting new deployment"
docker-compose -f $COMPOSE_FILE up -d --build

docker ps
echo "Deployment complete on port $PORT"
