#!/bin/bash

# Load configuration
CONFIG=$(cat ../config/docker-config.json)
GITHUB_USER=$(echo $CONFIG | jq -r '.github_user')
BACKEND_IMAGE_NAME=$(echo $CONFIG | jq -r '.backend_image_name')
VERSION_BACKEND=$(echo $CONFIG | jq -r '.version_backend')
PAT_FILE=$(echo $CONFIG | jq -r '.pat_file')
BACKEND_CONTAINER_NAME=$(echo $CONFIG | jq -r '.backend_container_name')

# Change to backend directory
cd ../src/app-backend || exit
echo "Building backend docker image..."
./gradlew build
echo "Build completed!"

# Stop and remove existing containers
docker ps -a | grep ${BACKEND_CONTAINER_NAME} | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep ${BACKEND_CONTAINER_NAME} | awk '{print $1}' | xargs -r docker rm

# Remove existing images
docker images | grep ${BACKEND_IMAGE_NAME} | awk '{print $3}' | xargs -r docker rmi -f

# Read GitHub PAT from file
GITHUB_PAT=$(cat "${PAT_FILE}")

# Construct image name
IMAGE_NAME="ghcr.io/${GITHUB_USER}/${BACKEND_IMAGE_NAME}:${VERSION_BACKEND}"

# Build and push the image
docker build -f Dockerfile -t "${IMAGE_NAME}" .

# Login to GitHub Container Registry
echo "${GITHUB_PAT}" | docker login ghcr.io -u "${GITHUB_USER}" --password-stdin

# Push the image
docker push "${IMAGE_NAME}"
docker tag "${IMAGE_NAME}" "${IMAGE_NAME}:${VERSION_BACKEND}"

# Logout from GitHub Container Registry
docker logout ghcr.io

# Return to scripts directory
cd ../../scripts || exit