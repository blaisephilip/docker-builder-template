#!/bin/bash

# Load configuration
CONFIG=$(cat ../config/docker-config.json)
GITHUB_USER=$(echo $CONFIG | jq -r '.github_user')
FRONTEND_IMAGE_NAME=$(echo $CONFIG | jq -r '.frontend_image_name')
VERSION_FRONTEND=$(echo $CONFIG | jq -r '.version_frontend')
PAT_FILE=$(echo $CONFIG | jq -r '.pat_file')

# Change to frontend directory
cd ../src/app-frontend || exit
echo "Building frontend docker image..."

# Stop and remove existing containers
docker ps -a | grep "tool-frontend" | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep "tool-frontend" | awk '{print $1}' | xargs -r docker rm

# Remove existing images
docker images | grep "tool-frontend" | awk '{print $3}' | xargs -r docker rmi -f

# Read GitHub PAT from file
GITHUB_PAT=$(cat "${PAT_FILE}")

# Construct image name
IMAGE_NAME="ghcr.io/${GITHUB_USER}/${FRONTEND_IMAGE_NAME}:${VERSION_FRONTEND}"

# Enable BuildKit for better secret handling
export DOCKER_BUILDKIT=1

# Build and push the image
docker build -f Dockerfile --secret id=npmrc,src="${HOME}/.npmrc" -t "${IMAGE_NAME}" .

# Login to GitHub Container Registry
echo "${GITHUB_PAT}" | docker login ghcr.io -u "${GITHUB_USER}" --password-stdin

# Push the image
docker push "${IMAGE_NAME}"
docker tag "${IMAGE_NAME}" "${IMAGE_NAME}:${VERSION_FRONTEND}"

# Logout from GitHub Container Registry
docker logout ghcr.io

# Return to scripts directory
cd ../../scripts || exit