
image_name="buildenv-simulations"
release="stable-amd64"
image_tag="$release"
container_name="${image_name}_${image_tag}"
architecture="linux/amd64"
image_repositories="docker.io/matthiasbock/$image_name registry.bihealth.org:443/bockm/recipes/$image_name"
