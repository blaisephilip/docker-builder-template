#!/bin/bash

echo "Setting up environment..."
sudo apt-get update
sudo apt install -y curl
sudo apt-get install jq docker.io 
sudo apt install docker-buildx nodejs

docker --version
node --version
npm --version

# Install Docker Buildx properly
echo "Installing Docker Buildx..."
mkdir -p ~/.docker/cli-plugins/
BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" -o ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx
# Verify buildx installation
docker buildx version
echo "Docker Buildx installed successfully."

cd ../src/app-backend || exit
echo "Setting up backend environment..."

# Initialize Gradle project
if [ ! -f "gradlew" ]; then
  echo "Gradle wrapper not found. Initializing Gradle project..."   
  gradle wrapper --gradle-version 8.5 --distribution-type bin
  gradle init
fi