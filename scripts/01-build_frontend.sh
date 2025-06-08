#!/bin/bash

# Attempt a local npm install to ensure all dependencies are available
# Change to app-frontend directory
cd ../src/app-frontend || exit
# Check if package-lock.json exists
if [ ! -f package-lock.json ]; then
    echo "package-lock.json not found. Running npm install..."
    # If package-lock.json does not exist, run npm install  
    npm install
else
    echo "package-lock.json available, cleaning up node modules..."
    if [ -d node_modules ]; then
        # If package-lock.json exists, remove node_modules directory
    rm -rf node_modules
    fi
fi
cd ../../scripts || exit

# Load configuration
CONFIG=$(cat ../config/docker-config.json)
GITHUB_USER=$(echo $CONFIG | jq -r '.github_user')
FRONTEND_IMAGE_NAME=$(echo $CONFIG | jq -r '.frontend_image_name')
VERSION_FRONTEND=$(echo $CONFIG | jq -r '.version_frontend')
PAT_FILE=$(echo $CONFIG | jq -r '.pat_file')

# Change to app-frontend directory
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

# Check if buildx is installed
#if ! docker buildx version > /dev/null 2>&1; then
#    echo "Error: Docker Buildx is not installed. Please install it first."
#    echo "Visit: https://docs.docker.com/go/buildx/"
#    exit 1
#fi

# Enable BuildKit for better secret handling
docker buildx create --use

# Build and push the image
# Use it like this if custom NPM package sources are needed
# DOCKER_BUILDKIT=1 docker build -f Dockerfile --secret id=npmrc,src="${HOME}/.npmrc" -t "${IMAGE_NAME}" .
# If no custom NPM package sources are needed, use the following command
DOCKER_BUILDKIT=1 docker build -f Dockerfile -t "${IMAGE_NAME}" .

# Login to GitHub Container Registry
echo "${GITHUB_PAT}" | docker login ghcr.io -u "${GITHUB_USER}" --password-stdin

# Push the image
#docker push "${IMAGE_NAME}"
echo "Image name: ${IMAGE_NAME}"
#docker tag "${IMAGE_NAME}" "${IMAGE_NAME}:${VERSION_FRONTEND}"

# Archive the image
echo "Archiving Docker image..."
ARCHIVE_PATH=$(echo $CONFIG | jq -r '.docker_img_archive_path')
ARCHIVE_NAME=$(echo $CONFIG | jq -r '.frontend_img_archive_name')
mkdir -p "../../$ARCHIVE_PATH"
# Save and compress the Docker image
docker save "${IMAGE_NAME}" | gzip > "../../${ARCHIVE_PATH}/${ARCHIVE_NAME}"
# Confirm archive creation
echo "Image archived to: ${ARCHIVE_PATH}/${ARCHIVE_NAME}"


# Logout from GitHub Container Registry
docker logout ghcr.io

# Return to scripts directory
cd ../../scripts || exit


# Launch container for testing
echo "Starting container for testing..."
docker run -d \
  -p 3000:3000 \
  --env-file ../src/app-frontend/.env \
  --name frontend-test \
  "${IMAGE_NAME}"

# Wait for container to start
sleep 3

# Check if container is running
if [ "$(docker ps -q -f name=frontend-test)" ]; then
    echo "Container started successfully on http://localhost:3000"
    
    # Open in Firefox private window
    if command -v firefox &> /dev/null; then
        firefox --private-window "http://localhost:3000" &
    else
        echo "Firefox not found. Please open http://localhost:3000 manually"
    fi
else
    echo "Error: Container failed to start"
    docker logs frontend-test
    exit 1
fi

# Wait for user input before cleanup
read -p "Press enter to stop the test container..."

# Cleanup
docker stop frontend-test
docker rm frontend-test
echo "Test container stopped and removed."
