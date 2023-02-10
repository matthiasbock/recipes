
export image_name="compute"
export release="base"
export architecture="amd64"
export image_tag="${release}"
export container_name="${image_name}-${image_tag}"

export base_image="docker.io/ubuntu:20.04"

export user="runner"
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"

export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"
