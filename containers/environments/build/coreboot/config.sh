
image_name="buildenv"
image_tag="coreboot"

debian_release="bullseye"
debian_architecture="amd64"
base_image="docker.io/matthiasbock/debian:$debian_release-$debian_architecture"

container_name="${image_name}_${image_tag}"
container_architecture="$debian_architecture"

user="runner"

repo_uri="https://review.coreboot.org/coreboot.git"
repo_dir="/home/$user/coreboot"

build_dependencies="git make m4 bison flex bzip2 xz-utils curl ccache zlib1g-dev g++ ccache gnat libncurses-dev cmake python"
multi_threading="-j8"

image_config="USER=$user WORKDIR=$repo_dir CMD=/bin/bash"

image_repositories="docker.io/matthiasbock/$image_name:$image_tag"


#
# TODO: Also pull the ccache from somewhere and append it to the container
#

function container_setup()
{
  # Install build dependencies
  container_exec $container_name apt-get -q update
  container_exec $container_name apt-get -q install -y $build_dependencies \
  || { echo "Failed to install dependencies. Aborting."; exit 1; }

  # Clone coreboot source repo
  container_exec $container_name git clone -q --depth=1 --recurse-submodules $repo_uri $repo_dir \
  || { echo "Failed to clone primary repository. Aborting."; exit 1; }

  # Build toolchain
  container_exec $container_name bash -c "cd '$repo_dir' && make $multi_threading iasl crossgcc"

  # Clean up
  container_expendables_import "$bash_container_library/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
