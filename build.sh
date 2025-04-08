#!/bin/bash

set -e

# Set variables
DEV_IMAGE="abisheak469/dev"
PROD_IMAGE="abisheak469/prod"
BRANCH=$(git rev-parse --abbrev-ref HEAD)
BUILD_NUMBER=${BUILD_NUMBER:-$(date +%s)}  # Use timestamp if BUILD_NUMBER is not set
IMAGE_TAG="${BUILD_NUMBER}"

# Docker login (assumes credentials are set as env vars)
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

# Determine image and compose file
if [ "$BRANCH" == "dev" ]; then
    IMAGE=$DEV_IMAGE
    COMPOSE_FILE="docker-compose.dev.yml"
elif [ "$BRANCH" == "master" ]; then
    IMAGE=$PROD_IMAGE
    COMPOSE_FILE="docker-compose.prod.yml"
else
    echo "Unsupported branch: $BRANCH"
    exit 1
fi

# Build and push
echo "Building image for $BRANCH using $COMPOSE_FILE"
docker-compose -f $COMPOSE_FILE build
docker tag ${IMAGE}:latest ${IMAGE}:${IMAGE_TAG}
docker push ${IMAGE}:${IMAGE_TAG}

echo "Build and push complete: ${IMAGE}:${IMAGE_TAG}"
