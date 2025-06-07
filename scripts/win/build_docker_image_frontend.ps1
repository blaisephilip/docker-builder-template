# Load configuration
$config = Get-Content -Path "../config/docker-config.json" | ConvertFrom-Json

Set-Location ../src/app-frontend
Write-Output "Building frontend docker image..."

# Stop and remove existing containers
docker ps -a | Where-Object { $_.Contains("tool-frontend") } | ForEach-Object { docker stop $_.Split(" ")[0] }
docker ps -a | Where-Object { $_.Contains("tool-frontend") } | ForEach-Object { docker rm $_.Split(" ")[0] }
$images = docker images | Where-Object { $_.Contains("tool-frontend") }

# Read GitHub PAT from file
$GITHUB_PAT = Get-Content -Path $config.pat_file

# Construct image name
$IMAGE_NAME = "ghcr.io/$($config.github_user)/$($config.frontend_image_name):$($config.version_frontend)"

# If there are any images, remove them
if ($images) {
    $images | ForEach-Object { docker image rm $_.Split(" ")[7] -f}
}

# Enable BuildKit for better secret handling
$env:DOCKER_BUILDKIT = "1"

exit

# Build and push the image
docker build -f Dockerfile --secret id=npmrc,src=$HOME/.npmrc -t $IMAGE_NAME .
docker login ghcr.io -u $config.github_user -p $GITHUB_PAT
docker push $IMAGE_NAME
docker tag $IMAGE_NAME "${$IMAGE_NAME}:$($config.version_frontend)"
docker logout ghcr.io
Set-Location ../../scripts/