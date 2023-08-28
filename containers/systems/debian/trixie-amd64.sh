
debian_release="trixie"
base_image="docker.io/debian:${debian_release}-slim"

target_architecture="amd64"
container_architecture="$target_architecture"
bootstrap_packages="libssl3"

. "$container_config_dir/common.sh"
