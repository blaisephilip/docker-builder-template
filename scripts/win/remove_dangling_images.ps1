# Get all Docker images
$images = docker images --format "{{.ID}} {{.Repository}} {{.Tag}}"

# Loop through each image
foreach ($image in $images)
{
    # Split the image string into ID and Repository
    $split = $image -split ' '
    $id = $split[0]
    # $repository = $split[1]
    $tag = $split[2]

    # If the repository is "<none>", remove the image
    if ($tag -eq "<none>")
    {
        docker rmi $id
    }
}
