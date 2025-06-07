#!/bin/bash

echo "Setting up environment..."
sudo apt-get update
sudo apt-get install jq
cd ../src/app-backend || exit
echo "Setting up backend environment..."

# Initialize Gradle project
if [ ! -f "gradlew" ]; then
  echo "Gradle wrapper not found. Initializing Gradle project..."   
  gradle wrapper --gradle-version 8.5 --distribution-type bin
  gradle init
fi