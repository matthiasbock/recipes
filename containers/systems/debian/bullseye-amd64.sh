
debian_release="bullseye"
base_image="docker.io/debian:${debian_release}-slim"

target_architecture="amd64"
container_architecture="$target_architecture"

. "$container_config_dir/common.sh"
