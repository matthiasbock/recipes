
image_name="buildenv"
image_tag="simulations"
debian_release="bullseye"
container_name="${image_name}_${image_tag}"
architecture="linux/amd64"

# Build image using Dockerfile
dockerfile="$container_config_dir/Dockerfile"

# Push image to repos
image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"
