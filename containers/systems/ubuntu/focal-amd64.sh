
base_image="docker.io/ubuntu:20.04"
ubuntu_release="focal"
target_architecture="amd64"
container_architecture="linux/$target_architecture"

. "$container_config_dir/common.sh"
