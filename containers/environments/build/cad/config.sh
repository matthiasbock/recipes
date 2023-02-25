
image_name="buildenv"
image_tag="cad"

debian_release="bullseye"
debian_architecture="amd64"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

user="runner"
image_config="USER=$user WORKDIR=$repo_dir CMD=/bin/bash"


# Derive container from this image:
base_image="registry.bihealth.org:443/bockm/recipes/debian:${debian_release}-${debian_architecture}"

# Install dependencies
APT_INSTALL_FROM="$container_config_dir/dependencies.txt"

# Push resulting image to these repos:
image_repositories="registry.bihealth.org:443/bockm/recipes/${image_name}:${image_tag}"
