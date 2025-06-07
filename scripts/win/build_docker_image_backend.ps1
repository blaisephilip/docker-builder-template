# Load configuration
$config = Get-Content -Path "../config/docker-config.json" | ConvertFrom-Json

Set-Location ../src/app-backend
echo "Building backend docker image..."
./gradlew.bat build
echo "Build completed!"

docker ps -a | Where-Object { $_.Contains($($config.backend_container_name)) } | ForEach-Object { docker stop $_.Split(" ")[0] }
docker ps -a | Where-Object { $_.Contains($($config.backend_container_name)) } | ForEach-Object { docker rm $_.Split(" ")[0] }
$images = docker images | Where-Object { $_.Contains($($config.backend_image_name)) }

# Read GitHub PAT from file
$GITHUB_PAT = Get-Content -Path $config.pat_file

# Construct image name
$IMAGE_NAME = "ghcr.io/$($config.github_user)/$($config.backend_image_name):$($config.version_backend)"

# If there are any images, remove them
if ($images) {
    $images | ForEach-Object { docker image rm $_.Split(" ")[7] -f}
}

# Build and push the image
docker build -f Dockerfile -t $IMAGE_NAME .

exit 0

docker login ghcr.io -u $config.github_user -p $GITHUB_PAT
docker push $IMAGE_NAME
docker tag $IMAGE_NAME "${IMAGE_NAME}:$($config.version_backend)"
docker logout ghcr.io
Set-Location ../../scripts/