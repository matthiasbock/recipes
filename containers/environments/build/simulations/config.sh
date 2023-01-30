
image_name="buildenv"
image_tag="simulations"
debian_release="bullseye"
container_name="${image_name}_${image_tag}"
architecture="linux/amd64"
image_repositories="docker.io/matthiasbock/$image_name:$image_tag registry.bihealth.org:443/bockm/recipes/$image_name:$image_tag"
