
export image_name="buildenv-coreboot"
export release="stable"
export architecture="amd64"
export image_tag="${architecture}"
export base_image="docker.io/matthiasbock/debian-base:${release}-${architecture}"
export container_name="${image_name}-${image_tag}"

export user="runner"
export hostname="${image_name}"

export repo_uri="https://review.coreboot.org/coreboot.git"
export repo_dir="/home/${user}/coreboot"
export image_config="USER=${user} WORKDIR=${repo_dir} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"

#
# TODO: Also pull the ccache from somewhere and append it to the container
#

function container_setup()
{
  container_debian_install_packages git make m4 bison flex bzip2 xz-utils curl ccache zlib1g-dev g++ gnat libncurses-dev cmake python \
   || { echo "Failed to install dependencies. Aborting."; exit 1; }
  container_exec $container_name git clone -q --depth=1 --recurse-submodules "$repo_uri" "$repo_dir" \
   || { echo "Failed to clone primary repository. Aborting."; exit 1; }

  # Build toolchain
  container_exec $container_name bash -c "cd '$repo_dir' && make iasl crossgcc"

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
