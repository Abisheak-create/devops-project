#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)
IMAGE_TAG=${BUILD_NUMBER}
DEV_IMAGE="abisheak469/dev"
PROD_IMAGE="abisheak469/prod"

if [[ "$BRANCH" == "dev" ]]; then
    IMAGE="$DEV_IMAGE"
    COMPOSE_FILE="docker-compose.dev.yml"
elif [[ "$BRANCH" == "master" ]]; then
    IMAGE="$PROD_IMAGE"
    COMPOSE_FILE="docker-compose.prod.yml"
else
    echo "No build config for branch: $BRANCH"
    exit 1
fi

echo "Building Docker image: $IMAGE:$IMAGE_TAG using $COMPOSE_FILE"
docker-compose -f $COMPOSE_FILE build
docker tag $IMAGE:latest $IMAGE:$IMAGE_TAG
docker push $IMAGE:$IMAGE_TAG
